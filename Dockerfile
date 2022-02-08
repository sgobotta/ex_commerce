# Find eligible builder and runner images on Docker Hub. We use Ubuntu/Debian instead of
# Alpine to avoid DNS resolution issues in production.
#
# https://hub.docker.com/r/hexpm/elixir/tags?page=1&name=ubuntu
# https://hub.docker.com/_/ubuntu?tab=tags
#
#
# This file is based on these images:
#
#   - https://hub.docker.com/r/hexpm/elixir/tags - for the build image
#   - https://hub.docker.com/_/debian?tab=tags&page=1&name=bullseye-20210902-slim - for the release image
#   - https://pkgs.org/ - resource for finding needed packages
#   - Ex: hexpm/elixir:1.12.3-erlang-23.3.4-debian-bullseye-20210902-slim
#
ARG BUILDER_IMAGE="hexpm/elixir:1.12.3-erlang-23.3.4-debian-bullseye-20210902-slim"
ARG RUNNER_IMAGE="debian:bullseye-20210902-slim"
ARG SECRET_KEY_BASE

FROM ${BUILDER_IMAGE} as builder

ENV ASDF_VERSION v0.9.0
ENV NODE_VERSION 16.13.1

# install build dependencies
RUN apt-get update -y && apt-get install -y build-essential git curl && \
    apt-get clean && rm -f /var/lib/apt/lists/*_* && \
    bash && \
    PATH="$HOME/.asdf/bin:$HOME/.asdf/shims:$PATH" && \
    echo "PATH=$HOME/.asdf/bin:$HOME/.asdf/shims:$PATH" >> ~/.bashrc && \
    git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch ${ASDF_VERSION} && \
    asdf plugin-add nodejs && \
    asdf install nodejs ${NODE_VERSION} && \
    asdf global nodejs ${NODE_VERSION}

SHELL ["/bin/bash", "--login", "-c"]

RUN asdf --version
RUN npm --version
RUN node --version

# prepare build dir
WORKDIR "/app"

# install hex + rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# set build ENV
ENV MIX_ENV="prod"
ENV SECRET_KEY_BASE=$SECRET_KEY_BASE

# install mix dependencies
COPY mix.exs mix.lock ./
COPY apps/ex_commerce/mix.exs ./apps/ex_commerce/mix.exs
COPY apps/ex_commerce_assets/mix.exs ./apps/ex_commerce_assets/mix.exs
COPY apps/ex_commerce_numeric/mix.exs ./apps/ex_commerce_numeric/mix.exs
COPY apps/ex_commerce_web/mix.exs ./apps/ex_commerce_web/mix.exs

RUN mix deps.get --only $MIX_ENV
RUN mkdir config

# copy compile-time config files before we compile dependencies
# to ensure any relevant config change will trigger the dependencies
# to be re-compiled.
COPY config/config.exs config/${MIX_ENV}.exs config/
RUN mix deps.compile

WORKDIR "/app"

# Compile the release
COPY apps apps

RUN MIX_ENV=prod mix compile

# Prepare web application assets
COPY apps/ex_commerce_web/priv ./apps/ex_commerce_web/priv

# Note: if your project uses a tool like https://purgecss.com/,
# which customizes asset compilation based on what it finds in
# your Elixir templates, you will need to move the asset compilation
# step down so that `lib` is available.
COPY apps/ex_commerce_web/assets ./apps/ex_commerce_web/assets

# Compile assets
WORKDIR "/app/apps/ex_commerce_web"
RUN MIX_ENV=prod mix compile
RUN npm install --prefix ./assets
RUN npm run deploy --prefix ./assets
RUN MIX_ENV=prod mix phx.digest

WORKDIR "/app"

# Changes to config/runtime.exs don't require recompiling the code
COPY config/runtime.exs config/

RUN mix release

# start a new build stage so that the final image will only contain
# the compiled release and other runtime necessities
FROM ${RUNNER_IMAGE}

RUN apt-get update -y && apt-get install -y libstdc++6 openssl libncurses5 locales \
  && apt-get clean && rm -f /var/lib/apt/lists/*_*

# Set the locale
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

WORKDIR "/app"
COPY entrypoint.sh .
RUN chmod +x entrypoint.sh
RUN chown nobody /app

# Only copy the final release from the build stage
COPY --from=builder --chown=nobody:root app/_build/prod/rel/ex_commerce .

USER nobody

CMD ["/app/entrypoint.sh"]
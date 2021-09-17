# ExCommerce

<p align="center">
  <a
    href=""
    target="_blank" rel="noopener noreferrer"
  >
    <img
      width="150px" src="logo.svg"
      alt="ExCommerce logo"
    />
  </a>
</p>

<h4 align="center">
  Elixir Marketplace Prototype
</h4>

<p align="center" style="margin-top: 14px;">
  <a href="https://github.com/sgobotta/ex_commerce/actions/workflows/dialyzer.yml">
    <img
      src="https://github.com/sgobotta/ex_commerce/actions/workflows/dialyzer.yml/badge.svg"
      alt="Code Analysis Status"
    >
  </a>
  <a href="https://github.com/sgobotta/ex_commerce/actions/workflows/test.yml">
    <img
      src="https://github.com/sgobotta/ex_commerce/actions/workflows/test.yml/badge.svg"
      alt="Tests Status"
    >
  </a>
  <a href="https://github.com/sgobotta/ex_commerce/actions/workflows/lint.yml">
    <img
      src="https://github.com/sgobotta/ex_commerce/actions/workflows/lint.yml/badge.svg"
      alt="Code Format Status"
    >
  </a>
</p>

<p align="center" style="margin-top: 14px;">
  <a href="https://www.codacy.com/gh/sgobotta/ex_commerce/dashboard?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=sgobotta/ex_commerce&amp;utm_campaign=Badge_Grade"
  >
    <img
      src="https://app.codacy.com/project/badge/Grade/5697c08197114d8d918c251be1b5d8a7"
      alt="Code Quality Status"
      />
    </a>
  <a href="https://coveralls.io/github/sgobotta/ex_commerce">
    <img
      src="https://coveralls.io/repos/github/sgobotta/ex_commerce/badge.svg"
      alt="Test Coverage Status"
    />
  </a>
</p>

<p align="center" style="margin-top: 14px;">
  <a
    href="https://github.com/sgobotta/ex_commerce/blob/main/LICENSE"
  >
    <img
      src="https://img.shields.io/badge/License-GPL%20v3-white.svg"
      alt="License"
    >
  </a>
</p>

## Development

### Requirements

+ [Docker](https://docs.docker.com/engine/install/ubuntu/)
+ [Docker Compose](https://docs.docker.com/compose/install/)
+ [Elixir `1.11.4`](https://elixir-lang.org/install.html)
+ [Erlang `23.3.4`](https://erlang.org/doc/installation_guide/users_guide.html)
+ [Node `14.16.1`](https://nodejs.org/es/)

Elixir, Erlang and Node can also be installed using [`asdf`](https://asdf-vm.com/#/core-manage-asdf?id=install). [Personal installation notes](https://gist.github.com/sgobotta/514a3e452f7bc37c558fc93a2768ccd2).

 ```bash
 asdf plugin-update --all
 asdf plugin-add erlang
 asdf plugin-add elixir
 asdf plugin-add nodejs
 asdf install
 ```

Versions inside `.tool-versions` will be installed.

### Recommended Editors and Extensions

+ [*VSCodium*](https://vscodium.com/#install), free alternative for VSCode.
+ [*VSCode*](https://code.visualstudio.com/Download)
+ [*ElixirLS*](https://marketplace.visualstudio.com/items?itemName=JakeBecker.elixir-ls) brings debugging, static analysis, formatting and code highlight support.
+ [*Elixir Linter (Credo)*](https://marketplace.visualstudio.com/items?itemName=pantajoe.vscode-elixir-credo) suggests code formatting, refactoring oportunities and promotes code consistency.
+ [*ESLint*](https://marketplace.visualstudio.com/items?itemName=dbaeumer.vscode-eslint) provides code consistency and beso practices for Javascript.
+ [*markdownlint*](https://marketplace.visualstudio.com/items?itemName=DavidAnson.vscode-markdownlint) brings consistency for writing documentation using markdown.

*NOTE: this toold help us detect issues that are eventually checked via git hooks or CI.*

### Git hooks

This project uses [`elixir_git_hooks`](https://github.com/qgadrian/elixir_git_hooks) t prevent common issues during the CI.

Git hooks implementation can be found in [`config/dev.exs`](config/dev.exs).

This hooks are automatically installed when the project compiles: `mix compile`. They can also be manually installed or run from a terminal:

+ Installation: `mix git_hooks.install`
+ Run a specific hook: `mix git_hooks.run pre_commit`
+ Run all hooks: `mix git_hooks.run all`

### Environment variables

Copy [`.env.example`](.env.example) to the project root and rename it [`.env`](.env). Then assign the following values:

```bash
cp .env.example .env
```

#### App

+ `APP_HOST`: a hsot IP. Example: `127.0.0.1` (local), `192.168.0.xxx` (lan), `0.0.0.0` (lan). This is mostly using in staging or production environments.

#### Database

+ `DB_USERNAME`: username for a root user in the development postgres database.
+ `DB_PASSWORD`: password for a root user in the development postgres database.
+ `DB_USERNAME_TEST`: same as `DB_USERNAME` for test development.
+ `DB_PASSWORD_TEST`: same as `DB_PASSWORD` for test development.

#### Mailing Service

+ `SENDGRID_API_KEY`: Sendgrid API key.

#### PgAdmin

+ `PGADMIN_DEFAULT_EMAIL`: email to access the Postgres Admin instance in the `pgadmin` container.
+ `PGADMIN_DEFAULT_PASSWORD`: password to access the Postgres Admin instance in the `pgadmin` container.

### Useful commands

This project uses **Makefile** to interact with the Elixir server, the postgres service, database and a variety of mix tools.

> *Displays helpful information about each command.*

```bash
make help
# Shortcut
make
```

#### Docker services commands

Docker services are defined in [`docker-compose.yml`](docker-compose.yml).

> *Starts dockerized services.*

```bash
make start
```

> *Stops dockerized services.*

```bash
make stop
```

#### Configuration commands

> *Installs a complete development environment. This is useful when changing branches or testing PRs with new dependencies.*

```bash
make setup
```

> *Installs dependencies only.*

```bash
make setup.deps
```

> *Simulates a complete envrionment re-installation. This is useful when stepping into client or server dependencies conflicts, migration issues or PR revisions that are not backwards compatible to current versions.*

```bash
make reset
```

> *Convenience for dropping the development database only.*

```bash
make reset.ecto
```

> *Convenience for dropping the testing database only.*

```bash
make reset.ecto.test
```

#### Server commands

> *Starts an Elixir server with an interactive shell sesion.*

```bash
make server
```

#### Testing commands

> *Runs all tests.*

```bash
make test
```

> *Runs only tests tagged with `wip` ([About tags and tests](https://hexdocs.pm/phoenix/testing.html#running-tests-using-tags)).*

```bash
make test.wip
```

> *Runs all tests, outputs coverage and generates an html report.*

```bash
make test.cover
```

> *Runs and watches all tests or those tagged with `wip`*

```bash
make test.watch
make test.wip.watch
```

#### Code analysis commands

Because some of this commands are executed in the [`lint.yml`](.github/workflows.lint.yml) workflow we recommend to run `make check` before applying changes to avoid conflicts in the CI. However, git hooks should notify errors and prevent commiting conflicting code when properly installed.

> *Formats code and analyzes code consistency, best practices and suggest refactoring opportunities.*

```bash
make lint
```

> *Similar to* `make lint` *but runs strictly: checks the code is properly formatted.*

```bash
make check.lint
```

> *Runs all available checks. Useful to test a branch before commiting.*

```bash
make check
```

### Development server

Once the environment file and the project is properly set up, a development server can be started using the command `make start` explained above.

+ Visit [`localhost:4000`](http://localhost:4000) from your browser to access the application main page.
+ Visit [`localhost:4000/dashboard`](http://localhost:4000/dashboard/home) from your browser to access a devellopment dashboard with information about your app.

### Database adminstration

The Docker services include a [`PostgreSql`](https://www.postgresql.org/) and a [`pgAdmin`](https://www.pgadmin.org/) instances.

+ Visit [`localhost:5050`](http://localhost:5050/) from your browser and use credentials configured in your [`.env`](.env.example) file to access the admin dhasboard.
+ Go to ***Object*** -> ***Create*** -> ***Server*** and type in a server name of your liking, e.g.: Dockerized Server.
+ Then, in the `Connection` tab use `main_db` as host (just how [`docker-compose.yml`](docker-compose.yml) defines the database service) and *Database* credentials configured in [`.env`](.env.example) to access the db.

## License

***TODO***

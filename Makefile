.PHONY: setup test

export MIX_ENV ?= dev

LOCAL_ENV_FILE = .env
PROD_ENV_FILE = .env.prod
APP_NAME = `grep 'APP_NAME=' .env | sed -e 's/\[//g' -e 's/ //g' -e 's/APP_NAME=//'`
DOCKER_BUILD_NAME = ${APP_NAME}_app

export GREEN=\033[0;32m
export NOFORMAT=\033[0m

default: help

#🐳 build: @ Builds a docker image
build: SHELL:=/bin/bash
build:
	@source ${LOCAL_ENV_FILE} && \
	docker build \
		--build-arg UPLOADS_PATH=${UPLOADS_PATH} \
		-t ${APP_NAME} .

#🔍 check: @ Runs all code verifications
check: check.lint check.dialyzer test

#🔍 check.dialyzer: @ Runs a static code analysis
check.dialyzer: SHELL:=/bin/bash
check.dialyzer:
	@source ${LOCAL_ENV_FILE} && mix check.dialyzer

#🔍 check.lint: @ Strictly runs a code formatter
check.lint: SHELL:=/bin/bash
check.lint:
	@source ${LOCAL_ENV_FILE} && mix check.format
	@source ${LOCAL_ENV_FILE} && mix check.credo

#🧹 clean.uploads: @ Removes all files from the uploads dir
clean.uploads: SHELL:=/bin/bash
clean.uploads:
	@source ${LOCAL_ENV_FILE} &&  \
		find ${DEV_UPLOADS_PATH} -path ${DEV_UPLOADS_PATH}/.gitkeep -prune -o -name "*.*" -exec /bin/rm -f {} \;

#🚀 deploy.heroku: @ Deploys the current branch to heroku main
deploy.heroku:
	@git push heroku $(shell git rev-parse --abbrev-ref HEAD):main

#📖 docs: @ Generates HTML documentation
docs:
	@mix docs

#❓ help: @ Displays this message
help:
	@echo ""
	@echo "List of available MAKE targets for development usage."
	@echo ""
	@echo "Usage: make [target]"
	@echo ""
	@echo "Examples:"
	@echo ""
	@echo "	make ${GREEN}start${NOFORMAT}	- Starts docker services"
	@echo "	make ${GREEN}setup${NOFORMAT}	- Set up the whole project and database"
	@echo "	make ${GREEN}server${NOFORMAT}	- Starts a development server"
	@echo "	make ${GREEN}stop${NOFORMAT}	- Stops docker services"
	@echo ""
	@grep -E '[a-zA-Z\.\-]+:.*?@ .*$$' $(MAKEFILE_LIST)| tr -d '#'  | awk 'BEGIN {FS = ":.*?@ "}; {printf "${GREEN}%-30s${NOFORMAT} %s\n", $$1, $$2}'

#💻 lint: @ Formats code
lint: SHELL:=/bin/bash
lint:
	@source ${LOCAL_ENV_FILE} && mix format
	@source ${LOCAL_ENV_FILE} && mix check.credo

#💣 reset: @ Cleans dependencies then re-installs and compiles them for all envs
reset: SHELL:=/bin/bash
reset: reset.dev reset.test

#💣 reset.dev: @ Cleans dependencies then re-installs and compiles them1 for dev env
reset.dev: SHELL:=/bin/bash
reset.dev:
	@echo "🧹 Cleaning db and dependencies for dev..."
	@source ${LOCAL_ENV_FILE} && MIX_ENV=dev mix reset

#💣 reset.test: @ Cleans dependencies then re-installs and compiles them1 for test env
reset.test: SHELL:=/bin/bash
reset.test:
	@echo "🧹 Cleaning db and dependencies for test..."
	@source ${LOCAL_ENV_FILE} && MIX_ENV=test mix reset

#💣 reset.ecto: @ Resets database for all envs
reset.ecto: SHELL:=/bin/bash
reset.ecto: reset.ecto.dev reset.ecto.test

#💣 reset.ecto.dev: @ Resets database for dev env
reset.ecto.dev: SHELL:=/bin/bash
reset.ecto.dev:
	@echo "🧹 Cleaning db for dev env..."
	@source ${LOCAL_ENV_FILE} && MIX_ENV=dev mix reset.ecto

#💣 reset.ecto.test: @ Resets database for test env
reset.ecto.test: SHELL:=/bin/bash
reset.ecto.test:
	@echo "🧹 Cleaning db for test env..."
	@source ${LOCAL_ENV_FILE} && MIX_ENV=test mix reset.ecto

#🐳 run: @ Runs a docker build
run:
	@docker run \
		-p 5000:5000 \
		--env-file ${PROD_ENV_FILE} \
		--name ${DOCKER_BUILD_NAME} \
		--net ${APP_NAME}_default \
		ex_commerce

#📦 setup: @ Installs dependencies and set up database for dev and test envs
setup: SHELL:=/bin/bash
setup: setup.dev setup.test

#📦 setup.dev: @ Installs dependencies and set up database for dev env
setup.dev: SHELL:=/bin/bash
setup.dev:
	@source ${LOCAL_ENV_FILE} && MIX_ENV=dev mix setup

#📦 setup.test: @ Installs dependencies and set up database for test env
setup.test: SHELL:=/bin/bash
setup.test:
	@source ${LOCAL_ENV_FILE} && MIX_ENV=test mix setup

#📦 setup.deps: @ Installs dependencies for development
setup.deps: setup.deps.dev setup.deps.test

#📦 setup.deps.ci: @ Installs dependencies for the CI environment
setup.deps.ci:
	@mix install

#📦 setup.deps.dev: @ Installs dependencies only for dev env
setup.deps.dev: SHELL:=/bin/bash
setup.deps.dev:
	@source ${LOCAL_ENV_FILE} && MIX_ENV=dev mix install

#📦 setup.deps.test: @ Installs dependencies only for test env
setup.deps.test: SHELL:=/bin/bash
setup.deps.test:
	@source ${LOCAL_ENV_FILE} && MIX_ENV=test mix install

#💻 server: @ Starts a server with an interactive elixir shell.
server: SHELL:=/bin/bash
server:
	@source ${LOCAL_ENV_FILE} && iex --name ${APP_NAME}@127.0.0.1 -S mix phx.server

#🐳 start: @ Starts docker-compose services
start: SHELL:=/bin/bash
start:
	@source .env && docker-compose up -d

#🐳 stop: @ Shuts down docker-compose services
stop:
	@docker-compose down

#🧪 test: @ Runs all test suites
test: MIX_ENV=test
test: SHELL:=/bin/bash
test:
	@source ${LOCAL_ENV_FILE} && mix test

#🧪 test.cover: @ Runs all tests and generates a coverage report
test.cover: MIX_ENV=test
test.cover: SHELL:=/bin/bash
test.cover:
	@source ${LOCAL_ENV_FILE} && mix coveralls.html --umbrella

#🧪 test.watch: @ Runs and watches all test suites
test.watch: SHELL:=/bin/bash
test.watch:
	@echo "🧪👁️  Watching all test suites..."
	@source ${LOCAL_ENV_FILE} && mix test.watch

#🧪 test.wip: @ Runs test suites that match the wip tag
test.wip: MIX_ENV=test
test.wip: SHELL:=/bin/bash
test.wip:
	@source ${LOCAL_ENV_FILE} && mix test --only wip

#🧪 test.wip.watch: @ Runs and watches test suites that match the wip tag
test.wip.watch: SHELL:=/bin/bash
test.wip.watch:
	@echo "🧪👁️  Watching test suites tagged with wip..."
	@source ${LOCAL_ENV_FILE} && mix test.watch --only wip

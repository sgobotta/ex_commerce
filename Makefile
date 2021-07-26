.PHONY: setup test

export MIX_ENV ?= dev

ENV_FILE = .env
APP_NAME = `grep 'APP_NAME=' .env | sed -e 's/\[//g' -e 's/ //g' -e 's/APP_NAME=//'`

default: help

#🔍 check: @ Runs all code verifications
check: check.lint check.dialyzer test

#🔍 check.dialyzer: @ Runs a static code analysis
check.dialyzer:
	@mix check.dialyzer

#🔍 check.lint: @ Strictly runs a code formatter
check.lint:
	@mix check.format
	@mix check.credo

#📖 docs: @ Generates HTML documentation
docs:
	@mix docs

#❓ help: @ Displays this message
help:
	@grep -E '[a-zA-Z\.\-]+:.*?@ .*$$' $(MAKEFILE_LIST)| tr -d '#'  | awk 'BEGIN {FS = ":.*?@ "}; {printf "\033[32m%-30s\033[0m %s\n", $$1, $$2}'

#💻 lint: @ Runs a code formatter
lint:
	@mix format
	@mix check.credo

#💣 reset: @ Cleans dependencies then re-installs and compiles them
reset:
	@echo "🧹 Cleaning db and dependencies..."
	@mix reset

#💣 reset.ecto: @ Resets database
reset.ecto:
	@mix reset.ecto

#📦 setup: @ Installs and compiles dependencies
setup:
	@mix setup

#💻 start: @ ‍💻 Starts a server with an interactive elixir shell.
start: SHELL:=/bin/bash
start:
	@source ${ENV_FILE} && iex --name ${APP_NAME}@127.0.0.1 -S mix phx.server

#🧪 test: @ Runs all test suites
test: MIX_ENV=test
test: SHELL:=/bin/bash
test:
	source ${ENV_FILE} && mix test

#🧪 test.cover: @ Runs mix tests and generates coverage
test.cover: MIX_ENV=test
test.cover: SHELL:=/bin/bash
test.cover:
	source ${ENV_FILE} && mix coveralls.html --umbrella

#🧪 test.watch: @ Runs and watches all test suites
test.watch: SHELL:=/bin/bash
test.watch:
	@echo "🧪👁️  Watching all test suites..."
	source ${ENV_FILE} && mix test.watch

#🧪 test.wip: @ Runs test suites that match the wip tag
test.wip: MIX_ENV=test
test.wip: SHELL:=/bin/bash
test.wip:
	source ${ENV_FILE} && mix test --only wip

#🧪 test.wip.watch: @ Runs and watches test suites that match the wip tag
test.wip.watch: SHELL:=/bin/bash
test.wip.watch:
	@echo "🧪👁️  Watching test suites tagged with wip..."
	source ${ENV_FILE} && mix test.watch --only wip

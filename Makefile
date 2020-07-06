SHELL := /bin/bash
ACTUAL := $(shell pwd)
MIX_ENV=dev

export MIX_ENV
export ACTUAL

help:
	@echo -e "Resuelve Auth Plug. \n\nAvailable commands:"
	@echo -e "\tmake debug\t Run the project in debug mode"
	@echo -e "\tmake doc\t Generate the project documentation."
	@echo -e "\tmake compile\t Compile the project"
	@echo -e "\tmake test\t Run the project tests"
	@echo -e "\tmake clean\t Deletes generated application files."

.PHONY: get
get:
	mix local.hex --force;
	mix local.rebar --force;
	mix deps;

debug:
	iex -S mix

doc: compile
	mix docs;
	tar -zcf docs.tar.gz doc/;

.NOTPARALLEL: test
.PHONY: test
test: MIX_ENV=test
test:
	mix test --trace;
	mix coveralls;

.NOTPARALLEL: compile
.PHONY: compile
compile: clean get
	mix compile;
	mix docs;
	tar -zcf docs.tar.gz doc/;

clean:
	mix clean
	mix deps.clean --all
	rm -rf doc/ docs.tar.gz

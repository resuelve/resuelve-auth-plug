SHELL := /bin/bash
ACTUAL := $(shell pwd)
MIX_ENV=dev

export MIX_ENV
export ACTUAL

help:
	@echo -e "Resuelve Auth Plug. \n\nComandos disponibles:"
	@echo -e "\tmake debug\t Ejecuta el proyecto en modo debug"
	@echo -e "\tmake doc\t Genera la documentación del proyecto"
	@echo -e "\tmake compile\t Compila el proyecto"
	@echo -e "\tmake test\t Ejecuta las pruebas del proyecto"
	@echo -e "\tmake release\t Compila el proyecto y genera el paquete a subir al servidor"
	@echo -e "\tmake clean\t Elimina los archivos generados por la compilación"

get:
	mix local.hex --force;
	mix local.rebar --force;
	mix deps.get;
	mix deps.compile;

debug:
	iex -S mix

doc: compile;
	mix docs;
	tar -zcf docs.tar.gz doc/;

test: MIX_ENV=test
	mix test --trace;
	mix coveralls;

compile: clean get
	mix compile;
	mix docs;
	tar -zcf docs.tar.gz doc/;

release: MIX_ENV=prod
release: compile
	mix escript.build

clean:
	mix clean
	mix deps.clean --all
	rm -rf doc/ docs.tar.gz

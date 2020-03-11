# Changelog


El formato de este documento está en base a [Keep a Changelog](https://keepachangelog.com/es-ES/1.0.0/),
y el proyecto se adhiere al [Versionado Semántico](https://semver.org/lang/es/).

## [v1.3] - (2020-03-12)

#### :boom: Soporte de nuevas versiones

## Cambios

* Se documentan los módulos del Plug
* Se agrega manejo de errores
* Se elimina dependencia Timex
* Se añaden pruebas unitarias
* Se realizan cambios para seguir las [reglas para crear bibliotecas en Elixir](https://hexdocs.pm/elixir/master/library-guidelines.html).

## Como usar esta versión

```elixir
def deps do
  [{:resuelve_auth, "~> v1.3"}]
end
```

Agregar el Plug a un pipeline.

```elixir
pipeline :api_auth do
  ...
  options = [
       secret: "secret", 
  		limit_time: 4,
  		handler: MyApp.AuthHandler
  		]
  plug ResuelveAuth.AuthPlug, options
end
```


## [v1.2.1] - (2020-03-09)

#### :boom: Refactor del plug

## Cambios

* Se agrega validación del `token` por tiempo.
* Se incorpora `travis-ci` para la integración continua
* Se registra en hexdocs.pm

## Cambios a realizar para actualizar a esta versión

Para usar en el proyecto:

```elixir
def deps do
  [ {:resuelve_auth, "~> 1.2.1"}]
end
```

Agregar Plug a un pipeline

```elixir
pipeline :api_auth do
  ...
  plug ResuelveAuth.Plugs.TokenAuth, "my-api"
end
```
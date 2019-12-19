[![Build Status](https://travis-ci.org/resuelve/resuelve-auth-plug.svg?branch=master)](https://travis-ci.org/resuelve/resuelve-auth-plug)
[![Coverage Status](https://coveralls.io/repos/github/resuelve/resuelve-auth-plug/badge.svg?branch=master)](https://coveralls.io/github/resuelve/resuelve-auth-plug?branch=master)

# ResuelveAuth

Plug para validar peticiones firmadas

## CONTENIDO

* [Agregar al proyecto](#add-project)
* [Configuración](#config)
* [Crear token y validarlo](#create-token)
* [Manejo de errores](#error-handler)
* [Errores](#errors)

<a name="add-project"></a>

## Agregar al proyecto

```elixir
def deps do
  [{:resuelve_auth, github: "resuelve/resuelve-auth-plug", tag: "v2.0"}]
end
```

Agregar Plug a un pipeline

```elixir
pipeline :api_auth do
  ...
  options = [secret: secret, 
  		limit_time: 4,
  		handler: ResuelveAuth.Sample.AuthHandler
  		]
  plug ResuelveAuth.AuthPlug, options
end
```

<a name="config"></a>

## Configuración

En tu proyeto puedes definir el nivel de logs que deseas manejar:

```elixir
# config/dev.exs
config :logger, :console, format: "[$level] $message\n"
 
# config/prod.exs
config :logger, level: :info

```

<a name="create-token"></a>

## Crear token y validarlo

```elixir
iex> alias ResuelveAuth.TokenData
iex> alias ResuelveAuth.Helpers.TokenHelper
iex> token_data = %TokenData{
      service: service,
      role: "service",
      meta: "metadata",
      timestamp: DateTime.to_unix(DateTime.utc_now(), :millisecond)
    }
iex> options = [secret: "super-secret-key", limit_time: 4]
iex> token = TokenHelper.create_token(token_data, options[:secret])
iex> {:ok, %{"meta" => meta}} = TokenHelper.verify_token(token, options)

```

<a name="errors"></a>

## Errores

Los siguientes son los errores que regresa el plug:

|   Error       | Descripción    |
| ------------- | -------------- |
| expired:      | El token ha expirado |
| unauthorized: | No autorizado |
| wrong_format: | Formato de token incorrecto |

<a name="error-handler"></a>

## Manejador de errores

Si el formato de respuesta no es el que se desea, se puede configurar la respuesta asociando un módulo como manejador de errores. 

```elixir
defmodule Module.Handler do
	  def errors(conn, reason) do
	  	# lógica para responde el error
	  end
end

iex> options = [secret: "super-secret-key", limit_time: 4, handler: Module.Handler]
iex> token = TokenHelper.verify_token(token, options)

```

La verificación de token `verify_token` realmente no se llama directamente, esta se invoca internamente en el plug cuando se manda a llamar la función `ResuelveAuth.Plugs.TokenAuth.call/2`.

Para saber más se puede consultar el módulo [ResuelveAuth.Sample.AuthHandler](lib/sample/auth_handler.ex).


## TODO

 - [x] Añadir proceso de integración continua
 - [x] Agregar herramientas para medir la covertura de código
 - [x] Automatizar la generación de documentación
 - [ ] Agregar el **CHANGELOG** del proyeto
 - [-] Documentar el proyecto

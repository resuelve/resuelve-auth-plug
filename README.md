[![Build Status](https://travis-ci.org/resuelve/resuelve-auth-plug.svg?branch=master)](https://travis-ci.org/resuelve/resuelve-auth-plug)
[![Coverage Status](https://coveralls.io/repos/github/resuelve/resuelve-auth-plug/badge.svg?branch=master)](https://coveralls.io/github/resuelve/resuelve-auth-plug?branch=master)

# ResuelveAuth

Plug para validar peticiones firmadas

## CONTENIDO

* [Agregar al proyecto](#add-project)
* [Configuración](#config)
* [Generación del secret](#key-gen)
* [Crear token y validarlo](#create-token)
* [Manejo de errores](#error-handler)
* [Errores](#errors)

<a name="add-project"></a>

## Agregar al proyecto

```elixir
def deps do
  [{:resuelve_auth, "~> v1.3"}]
end
```

Agregar el Plug a un pipeline, siguiendo las [guías para crear bibliotecas en Elixir](https://hexdocs.pm/elixir/master/library-guidelines.html), se configuran las opciones y se puede enviar al plug.

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

También se puede definir una función que se encargará de obtener el secret en tiempo de ejecución, esto para evitar que se asigne un valor `nil` al plug durante la compilación.

Teniendo un módulo que se encargue de obtner el `secret` de algún lugar.

```elixir
defmodule Vault do
  def get_secret, do: "super secret"
end
```

```elixir
pipeline :api_auth do
  ...
  options = [
       secret: &Vault.get_secret/0,
  		limit_time: 4,
  		handler: MyApp.AuthHandler
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

## Creación del secret

Si se tiene un proyecto con phoenix se puede generar una llave con el comando:

```terminal
$> mix phx.gen.secret 32
TICxDq3wquPi49UuMfA4PjnWpz1PqnB1

$> mix phx.gen.secret 64
b9sq3yGrwWKXxpNfx3+a8hEaRa3S5QWMiRg+gPpbzc54ZpjVaqDYD3DRbPuYx621

```

Otra forma de generar un secret es:

```terminal
$> date +%s | sha256sum | base64 | head -c 32 ; echo
MGYwM2M1Njk1MGIxYjcyOGY3OTc0ZDk0

$> date +%s | sha256sum | base64 | head -c 64 ; echo
ZGZhMzZhOWQyZTViOWQxNWIyY2NlMGExMDVhMzQ1ZGNkODA1YWUxNmRmMWRjMGZi

```

Con openssl:

```elixir
$> openssl rand -base64 32
//ZE5siYI04Bp/2JtFq3uJOpS4XXChADe8b9RHenzFY=

$> openssl rand -base64 64
qlTw8sjiavcPAKIHJbO/zOUqLCS99zmyerjnoRc6FumLIc/Q9K9TjitS4JmTFh5r
3ULjJAMfkouTR1OUV4LZ4Q==

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

Basta con que exista una función llamada `errors/2` en el handler para que se pueda responder apropiadamente el error, los parámetros son la conección y un objeto que contenga el mensaje de error. 

La verificación de token `verify_token` realmente no se llama directamente, esta se invoca internamente en el plug cuando se manda a llamar la función `ResuelveAuth.Plugs.TokenAuth.call/2`.

Para saber más se puede consultar el módulo [ResuelveAuth.Sample.AuthHandler](lib/sample/auth_handler.ex).


## TODO

 - [x] Añadir proceso de integración continua
 - [x] Agregar herramientas para medir la covertura de código
 - [x] Automatizar la generación de documentación
 - [x] Agregar el **CHANGELOG** del proyeto
 - [x] Documentar el proyecto

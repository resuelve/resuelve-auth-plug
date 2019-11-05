[![Build Status](https://travis-ci.org/iver/resuelve-auth-plug.svg?branch=master)](https://travis-ci.org/iver/resuelve-auth-plug)
[![Coverage Status](https://coveralls.io/repos/github/iver/resuelve-auth-plug/badge.svg?branch=master)](https://coveralls.io/github/iver/resuelve-auth-plug?branch=master)

# ResuelveAuth

Plug para validar peticiones firmadas

## Agregar al proyecto

```
def deps do
  [{:resuelve_auth, github: "resuelve/resuelve-auth-plug", tag: "v2.0"}]
end
```

Agregar Plug a un pipeline
```
pipeline :api_auth do
  ...
  plug ResuelveAuth.AuthPlug, "my-api"
end
```

## Configuración

En tu proyeto puedes definir el nivel de logs que deseas manejar:

```elixir
# config/dev.exs
config :logger, :console, format: "[$level] $message\n"
 
# config/prod.exs
config :logger, level: :info
```

## Crear token y validarlo

```
iex> alias ResuelveAuth.TokenData
iex> alias ResuelveAuth.Helpers.TokenHelper
iex> token_data = %TokenData{
  service: "my-service",
  meta: %{
    stuff: "some-stuff"
  }
}
iex> token = TokenHelper.create_token(token_data, "super-secret")
iex> {:ok, %{"meta" => meta}} = TokenHelper.verify_token(token, "super-secret")
iex> {:error, "Unauthorized"} = TokenHelper.verify_token(token, "invalid-secret-or-invalid-token")
```

## TODO

 - [] Añadir proceso de integración continua
 - [] Agregar el **CHANGELOG** del proyeto
 - [] Documentar el proyecto
 - [] Agregar herramientas para medir la covertura de código
 - [] Automatizar la generación de documentación

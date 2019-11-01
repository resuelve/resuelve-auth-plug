# ResuelveAuth

Plug para validar peticiones firmadas

## Agregar al proyecto

```
def deps do
  [{:resuelve_auth, github: "resuelve/resuelve-auth-plug", tag: "v1.2"}]
end
```

Agregar Plug a un pipeline
```
pipeline :api_auth do
  ...
  plug ResuelveAuth.Plugs.TokenAuth, "my-api"
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
iex> alias ResuelveAuth.Helpers.TokenData
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

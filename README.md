# ResuelveAuth

Plug para validar peticiones firmadas

## Configuración
**Sin token logs**:
```
config :resuelve_auth,
  no_logs: true
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

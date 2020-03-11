defmodule ResuelveAuth.AuthPlug do
  @moduledoc """
  Plug para autenticacion mediante verificacion de firma de tokens.

  Valores por defecto:

  - limit_time: 1 semana en horas
  - secret:     llave para generar el token vacia
  - handler:    Módulo de ejemplo para responder errores

  ## Ejemplo:

  ```exlir

  # En el archivo router.ex
  defmodule MyApi.Router do

    # Se usan 10 horas como vigencia del token y
    # se toma el comportamiento por defecto del handler.
    @options [secret: "mi-llave-secreta", limit_time: 10]
    use MyApi, :router

    pipeline :auth do
      plug ResuelveAuth.AuthPlug, @options
    end

    scope "/v1", MyApi do
      pipe_through([:auth])
      ..
      post("/users/", UserController, :create)
    end
  end

  ```

  """

  import Plug.Conn
  alias ResuelveAuth.Helpers.TokenHelper

  @behaviour Plug

  @default [
    limit_time: 168,
    secret: "",
    handler: ResuelveAuth.Sample.AuthHandler
  ]

  @impl Plug
  def init(options) do
    Keyword.merge(@default, options)
  end

  @impl Plug
  def call(%Plug.Conn{} = conn, options) do
    with [token] <- get_req_header(conn, "authorization"),
         {:ok, data} <- TokenHelper.verify_token(token, options) do
      assign(conn, :session, data)
    else
      {:error, reason} ->
        options[:handler].errors(conn, reason)

      _ ->
        options[:handler].errors(conn, "Unauthorized")
    end
  end
end

defmodule ResuelveAuth.AuthPlug do
  @moduledoc """
  Plug for authentication using token signature verification.

  | Option  | Description | Default value |
  | ------- | ----------- | ------------- |
  | limit_time | time in hours | 168 h (1 w) |
  | secret  | Secret key | empty  |
  | handler | Error handler function | ResuelveAuth.Sample.AuthHandler |

  ## Example

  ```elixir

  # En el archivo router.ex
  defmodule MyApi.Router do

    # Using 10 hours as limit and default error handler
    @options [secret: "my-secret-key", limit_time: 10]
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

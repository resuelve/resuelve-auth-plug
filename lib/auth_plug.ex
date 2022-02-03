defmodule ResuelveAuth.AuthPlug do
  @moduledoc """
  Plug for authentication using token signature verification.

  ## Basic Usage

  In your router, append the plug to a pipeline. Example:

  ```elixir
  defmodule MyApp.Router do
    ...
    pipeline :auth do
      plug(ResuelveAuth.AuthPlug)
    end
    ...
  end
  ```

  ## Configuration

  Here's the list of options available:

  | Option  | Description | Default value |
  | ------- | ----------- | ------------- |
  | limit_time | Token lifespan in hours | 168 (1 week) |
  | secret  | Secret key | empty  |
  | handler | Error handler function | ResuelveAuth.Sample.AuthHandler |

  You can declare global or per environment configuration for the plug in your config files.

  ```elixir
  # In config/{config|prod|dev|test|runtime}.exs
  config :resuelve_auth,
    secret: "my-secret-key",
    limit_time: 24,
    handler: MyApp.MyAuthHandler
  ```

  Or you can pass a keyword list of options to the plug declaration.

  ```elixir
    pipeline :auth do
      plug(ResuelveAuth.AuthPlug, secret: "my-secret-key", ...)
    end
  ```
  """

  import Plug.Conn
  alias ResuelveAuth.Helpers.TokenHelper

  @behaviour Plug

  @defaults [
    limit_time: 168,
    secret: "",
    handler: ResuelveAuth.Sample.AuthHandler
  ]

  @impl Plug
  def init(options) do
    @defaults
    |> Keyword.merge(Application.get_all_env(:resuelve_auth))
    |> Keyword.merge(options)
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

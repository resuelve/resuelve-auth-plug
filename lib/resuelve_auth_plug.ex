defmodule ResuelveAuth.Plugs.TokenAuth do
  @moduledoc """
  Plug para autenticacion mediante verificacion de firma de tokens.
  """

  import Plug.Conn
  alias ResuelveAuth.Helpers.TokenHelper

  def init(default), do: default

  def call(%Plug.Conn{} = conn, _default) do
    secret = Application.get_env(:resuelve_auth, :secret)
    handler = Application.get_env(:resuelve_auth, :handler)

    with [token] <- get_req_header(conn, "authorization"),
      {:ok, data} <- TokenHelper.verify_token(token, secret) do
        assign(conn, :session, data)
    else
      {:error, reason} -> handler.errors(conn, reason)
      _ -> handler.errors(conn, "authorization token not found.")
    end
  end
end

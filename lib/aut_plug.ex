defmodule ResuelveAuth.AuthPlug do
  @moduledoc """
  Plug para autenticacion mediante verificacion de firma de tokens.
  """

  import Plug.Conn
  alias ResuelveAuth.Helpers.TokenHelper

  @behaviour Plug

  @impl Plug
  def init(default), do: default

  @impl Plug
  def call(%Plug.Conn{} = conn, _default) do
    secret = Application.get_env(:resuelve_auth, :secret)
    handler = Application.get_env(:resuelve_auth, :handler)

    with [token] <- get_req_header(conn, "authorization"),
         {:ok, data} <- TokenHelper.verify_token(token, secret) do
      assign(conn, :session, data)
    else
      {:error, reason} -> handler.errors(conn, reason)
      _ -> handler.errors(conn, "Unauthorized")
    end
  end
end

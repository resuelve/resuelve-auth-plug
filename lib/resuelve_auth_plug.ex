defmodule ResuelveAuth.Plugs.TokenAuth do
  @moduledoc """
  Plug para autenticacion mediante verificacion de firma de tokens.
  """

  import Plug.Conn
  alias ResuelveAuth.Helpers.TokenHelper

  def init(default), do: default

  def call(%Plug.Conn{} = conn, _default) do

    [token] = get_req_header(conn, "authorization")
    secret = Application.get_env(:resuelve_auth, :secret)
    handler = Application.get_env(:resuelve_auth, :handler)

    case TokenHelper.verify_token(token, secret) do
      {:ok, data} ->
        conn
        |> assign(:session, data)
      {:error, reason} ->
        # handler.errors(conn, reason)
        send_resp(conn, 401, "error")
    end
  end
end

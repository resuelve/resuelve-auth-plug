defmodule ResuelveAuth.Sample.AuthHandler do
  @moduledoc """
  Ejemplo de una implementación de un handler para la autenticación.
  """
  import Plug.Conn
  require Logger

  @doc """
  Maneja los errores que puede responder el plug
  """
  @spec errors(map, String.t()) :: any
  def errors(conn, reason) do
    Logger.error(fn -> "Token no valido: #{inspect(reason)}" end)
    response = Poison.encode!(%{data: nil, errors: %{detail: reason}})

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(:unauthorized, response)
    |> halt
  end
end

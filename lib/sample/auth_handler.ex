defmodule ResuelveAuth.Sample.AuthHandler do
  @moduledoc """
  Ejemplo de una implementación de un handler para la autenticación.
  """
  import Plug.Conn
  require Logger

  @errors [
    expired: "token has expired",
    unauthorized: "unauthorized",
    wrong_format: "wrong format",
    invalid_unix_time: "invalid unix time"
  ]

  @doc """
  Maneja los errores que puede responder el plug
  """
  @spec errors(map, String.t()) :: any
  def errors(conn, message) do
    Logger.error(fn -> "Token no valido: #{inspect(message)}" end)
    detail = reason(message)
    response = Poison.encode!(%{data: nil, errors: %{detail: detail}})

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(:unauthorized, response)
    |> halt
  end

  def reason(reason) do
    case @errors[reason] do
      nil -> @errors[:unauthorized]
      default -> default
    end
  end
end

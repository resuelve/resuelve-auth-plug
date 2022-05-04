defmodule ResuelveAuth.Sample.AuthHandler do
  @moduledoc """
  Example of implementing an error handler.
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
  Handles errors that the plug can respond to
  """
  @spec errors(%Plug.Conn{}, String.t()) :: %Plug.Conn{}
  def errors(conn, message) do
    Logger.error(fn -> "Invalid token: #{inspect(message)}" end)
    detail = reason(message)
    response = Poison.encode!(%{data: nil, errors: %{detail: detail}})

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(:unauthorized, response)
    |> halt
  end

  def reason(reason) when reason in @errors, do: @errors[reason]

  def reason(_any), do: @errors[:unauthorized]
end

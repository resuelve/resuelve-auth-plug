defmodule ResuelveAuth.TokenData do
  @moduledoc """
  Estructura que define los elementos de un token
  """

  alias ResuelveAuth.Utils.Secret

  defstruct [:service, :role, :session, :timestamp, :meta]

  @errors [wrong_format: "wrong format", unauthorized: "unauthorized"]

  def cast(token, secret) do
    token
    |> String.contains?(".")
    |> split(token)
    |> is_equivalent(secret)
  end

  defp split(false, _reason), do: {:error, @errors[:wrong_format]}

  defp split(true, token) do
    [data, sign] = String.split(token, ".")
    {:ok, %{data: data, sign: sign}}
  end

  defp is_equivalent({:error, reason}, _secret), do: {:error, reason}

  defp is_equivalent({:ok, %{data: data, sign: sign}}, secret) do
    data
    |> Secret.cypher(sign, secret)
    |> Secret.equivalent?(sign)
    |> case do
      true -> {:ok, data}
      false -> {:error, @errors[:unauthorized]}
    end
  end
end

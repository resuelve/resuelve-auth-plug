defmodule ResuelveAuth.TokenData do
  @moduledoc """
  Estructura para datos genericos del token
  """

  alias ResuelveAuth.Utils.Secret

  defstruct [:service, :role, :session, :timestamp, :meta]

  @error "Unauthorized"

  def cast(token, secret) do
    token
    |> String.contains?(".")
    |> split(token)
    |> is_equivalent(secret)
  end

  defp split(false, _reason), do: {:error, @error}

  defp split(true, token) do
    [data, sign] = String.split(token, ".")
    {:ok, %{data: data, sign: sign}}
  end

  defp is_equivalent({:error, _reason}, _secret), do: {:error, @error}

  defp is_equivalent({:ok, %{data: data, sign: sign}}, secret) do
    data
    |> Secret.cypher(sign, secret)
    |> Secret.equivalent?(sign)
    |> case do
      true -> {:ok, data}
      false -> {:error, @error}
    end
  end
end

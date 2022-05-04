defmodule ResuelveAuth.TokenData do
  @moduledoc """
  Structure that defines the elements of a token.
  """

  alias ResuelveAuth.Utils.Secret

  # It's used by NuLogin to manage the token's TTL
  @day_in_ms 86_400_000

  defstruct [:service, :role, :session, :timestamp, :meta, {:expiration, @day_in_ms}]

  @doc """
  Convert token to valid data or return an error.
  """
  @spec cast(String.t(), String.t()) :: {:error, atom()} | {:ok, String.t()}
  def cast(token, secret) do
    with [data | [sign | _]] <- split(token) do
      is_equivalent(data, sign, secret)
    else
      _ -> {:error, :wrong_format}
    end
  end

  @spec split(String.t()) :: list()
  defp split(token) when is_binary(token), do: String.split(token, ".")
  defp split(_token), do: []

  @spec is_equivalent(String.t(), String.t(), String.t()) ::
          {:error, atom()} | {:ok, String.t()}
  defp is_equivalent(data, sign, secret) do
    data
    |> Secret.cypher(sign, secret)
    |> Secret.equivalent?(sign)
    |> case do
      true -> {:ok, data}
      false -> {:error, :unauthorized}
    end
  end
end

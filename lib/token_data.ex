defmodule ResuelveAuth.TokenData do
  @moduledoc """
  Estructura que define los elementos de un token
  """

  alias ResuelveAuth.Utils.Secret

  defstruct [:service, :role, :session, :timestamp, :meta]

  @doc """
  Convierte el token a datos válidos o regresa un error.
  """
  @spec cast(String.t(), String.t()) :: {:ok, %{}} | {:error, String.t()}
  def cast(token, secret) do
    token
    |> String.contains?(".")
    |> split(token)
    |> is_equivalent(secret)
  end

  @spec split(false, String.t()) :: {:error, String.t()}
  defp split(false, _reason), do: {:error, :wrong_format}

  @spec split(true, String.t()) :: {:ok, %{}}
  defp split(true, token) do
    [data, sign] = String.split(token, ".")
    {:ok, %{data: data, sign: sign}}
  end

  @spec is_equivalent({:error, String.t()}, String.t()) :: {:error, String.t()}
  defp is_equivalent({:error, reason}, _secret), do: {:error, reason}

  @spec is_equivalent({:ok, %{}}, String.t()) ::
          {:ok, %{}} | {:error, String.t()}
  defp is_equivalent({:ok, %{data: data, sign: sign}}, secret) do
    data
    |> Secret.cypher(sign, secret)
    |> Secret.equivalent?(sign)
    |> case do
      true -> {:ok, data}
      false -> {:error, :unauthorized}
    end
  end
end

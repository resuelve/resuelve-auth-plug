defmodule ResuelveAuth.Utils.Secret do
  @moduledoc """
  Contiene lógica de codificación, decodificación, cifrado y descifrado.
  """
  @legend "Error al firmar el Token: "
  require Logger

  @doc """
  Firma la información con una semilla (`secret`) pasando primero por un
  proceso de códificación.
  """
  @spec sign(%{}, String.t()) :: String.t()
  def sign(data, secret) do
    data
    |> encode()
    |> encode64()
    |> cypher(secret)
    |> join()
  end

  @spec encode(%{}) :: tuple()
  def encode(input), do: Poison.encode(input)

  @spec decode(tuple() | %{}) :: {:ok, any()} | {:error, any()}
  def decode({:ok, json}), do: decode(json)
  def decode({:error, reason}), do: Logger.error("#{@legend} #{reason}")
  def decode(input), do: Poison.decode(input)

  @spec encode64(tuple() | %{}) :: {:ok, any()} | {:error, any()}
  def encode64({:ok, json}), do: encode64(json)
  def encode64({:error, reason}), do: Logger.error("#{@legend} #{reason}")
  def encode64(input), do: Base.url_encode64(input)

  @spec decode64(%{}) :: tuple()
  def decode64(input), do: Base.url_decode64(input)

  def cypher({:error, reason}), do: Logger.error("#{@legend} #{reason}")
  def cypher({:ok, json}, secret), do: cypher(json, secret)

  def cypher(data, secret) do
    sign = Base.encode16(:crypto.hmac(:sha256, secret, data))
    %{data: data, sign: sign}
  end

  def cypher(data, sign, secret) do
    %{sign: valid_sign} = cypher(data, secret)
    %{data: data, valid: valid_sign, sign: sign}
  end

  def equivalent?(%{valid: valid}, sign), do: String.equivalent?(valid, sign)

  # Regresa los valores de la tupla concatenados por un punto
  defp join(%{data: data, sign: sign}), do: "#{data}.#{sign}"
end

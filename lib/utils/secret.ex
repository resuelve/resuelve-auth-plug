defmodule ResuelveAuth.Utils.Secret do
  @moduledoc """
  Contiene lógica de codificación, decodificación, cifrado y descifrado.
  """
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

  @spec encode64(tuple() | %{}) :: {:ok, any()} | {:error, any()}
  def encode64({:ok, json}), do: encode64(json)

  def encode64({:error, reason} = error) do
    Logger.error(fn -> "#{reason}" end)
    error
  end

  def encode64(input), do: Base.url_encode64(input)

  @spec decode64(%{}) :: tuple()
  def decode64(input), do: Base.url_decode64(input)

  @spec decode(tuple() | %{}) :: {:ok, any()} | {:error, any()}
  def decode({:ok, json}), do: decode(json)

  def decode({:error, reason} = result) do
    Logger.error(fn -> "#{reason}" end)
    result
  end

  @spec decode(%{}) :: {:ok, any()} | {:error, any()}
  def decode(input), do: Poison.decode(input)

  def cypher({:error, reason} = _params) do
    Logger.error(fn -> "#{reason}" end)
    {:error, :wrong_format}
  end

  def cypher({:ok, json}, secret), do: cypher(json, secret)

  def cypher(data, secret) do
    sign = Base.encode16(:crypto.hmac(:sha256, secret, data))
    %{data: data, sign: sign}
  end

  def cypher(data, sign, secret) do
    %{sign: valid_sign} = cypher(data, secret)
    %{data: data, valid: valid_sign, sign: sign}
  end

  @doc """
  Identifica si la tupla de la cadena firmada es válida de acuerdo al token enviado.
  ## Ejemplo:

  ```elixir

  iex> alias ResuelveAuth.Utils.Secret
  iex> data = {:error, "mensaje de error"}
  iex> Secret.equivalent?(data)
  {:error, "mensaje de error"}

  iex> alias ResuelveAuth.Utils.Secret
  iex> data = %{valid: "datos", "firma"}
  iex> Secret.equivalent?(data)
  false

  ```

  """
  @spec equivalent?({:error, String.t()}) :: {:error, String.t()}
  def equivalent?({:error, _reason} = params), do: params

  @spec equivalent?(%{}, String.t()) :: boolean()
  def equivalent?(%{valid: valid}, sign), do: String.equivalent?(valid, sign)

  # Regresa los valores de la tupla concatenados por un punto
  defp join(%{data: data, sign: sign}), do: "#{data}.#{sign}"
end

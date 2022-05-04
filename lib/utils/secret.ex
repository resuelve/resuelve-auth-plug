defmodule ResuelveAuth.Utils.Secret do
  @moduledoc """
  Contains encoding, decoding, encryption, and decryption logic.
  """
  require Logger

  @doc """
  Sign the information with a seed (`secret`)
  by first going through a coding process.
  """
  @spec sign(%{}, list()) :: String.t()
  def sign(data, options) when is_list(options) do
    secret = options[:secret]

    data
    |> encode()
    |> encode64()
    |> cypher(secret)
    |> join()
  end

  @spec encode(map()) :: {:ok, String.t()} | {:error, any()}
  def encode(input), do: Poison.encode(input, strict_keys: true)

  @spec encode64(tuple() | %{}) :: String.t() | {:error, any()}
  def encode64({:ok, json}), do: encode64(json)

  def encode64({:error, reason} = error) do
    Logger.error(fn -> "#{inspect(reason)}" end)
    error
  end

  def encode64(input), do: Base.url_encode64(input)

  @spec decode64(binary()) :: {:ok, binary()} | :error
  def decode64(input), do: Base.url_decode64(input)

  @spec decode(tuple() | %{}) :: {:ok, any()} | {:error, any()}
  def decode({:ok, json}), do: decode(json)

  def decode({:error, reason} = result) do
    Logger.error(fn -> "#{inspect(reason)}" end)
    result
  end

  def decode(input), do: Poison.decode(input)

  def cypher({:error, reason} = _params, _secret) do
    Logger.error(fn -> "#{inspect(reason)}" end)
    {:error, :wrong_format}
  end

  def cypher({:ok, json}, secret), do: cypher(json, secret)

  def cypher(data, secret) do
    sign =
      if String.to_integer(System.otp_release) >= 23 do
        Base.encode16(:crypto.mac(:hmac, :sha256, secret, data))
      else
        Base.encode16(:crypto.hmac(:sha256, secret, data))
      end

    %{data: data, sign: sign}
  end

  def cypher(data, sign, secret) do
    %{sign: valid_sign} = cypher(data, secret)
    %{data: data, valid: valid_sign, sign: sign}
  end

  @doc """
  Identify if the tuple of the signed string is valid according to the sent token.

  ## Example

  ```elixir

  iex> alias ResuelveAuth.Utils.Secret
  iex> data = %{valid: "datos"}
  iex> Secret.equivalent?(data, "datos")
  true

  iex> alias ResuelveAuth.Utils.Secret
  iex> data = {:error, "error message"}
  iex> Secret.equivalent?(data, "data")
  {:error, "error message"}

  ```

  """
  @spec equivalent?({:error, String.t()}, String.t() | nil) ::
          {:error, String.t()}
  def equivalent?({:error, _reason} = params, _any), do: params

  @spec equivalent?(map(), String.t()) :: boolean()
  def equivalent?(%{valid: valid}, sign), do: String.equivalent?(valid, sign)

  # Returns the tuple values ​​concatenated by a dot
  defp join(%{data: data, sign: sign}), do: "#{data}.#{sign}"
end

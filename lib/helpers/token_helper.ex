defmodule ResuelveAuth.Helpers.TokenHelper do
  @moduledoc """
  Token generation and validation module.
  """

  require Logger
  alias ResuelveAuth.TokenData
  alias ResuelveAuth.Utils.Calendar
  alias ResuelveAuth.Utils.Secret

  @doc """
  Returns token generated from a map in the following format
  SECURE_BASE64_JSON.SIGNATURE_HMAC_SHA_256_BASE16

  ## Examples

  ```elixir

     iex> alias ResuelveAuth.TokenData
     iex> timestamp = 1572656155135
     iex> data = %TokenData{ \
     meta: nil, \
     role: "service", \
     service: "my-api", \
     session: nil, \
     timestamp: timestamp \
     }
     iex> options = [secret: "secret", limit_time: 4]
     iex> alias ResuelveAuth.Helpers.TokenHelper
     iex> token = TokenHelper.create_token(data, options)
     "eyJ0aW1lc3RhbXAiOjE1NzI2NTYxNTUxMzUsInNlc3Npb24iOm51bGwsInNlcnZpY2UiOiJteS1hcGkiLCJyb2xlIjoic2VydmljZSIsIm1ldGEiOm51bGwsImV4cGlyYXRpb24iOjg2NDAwMDAwfQ==.0BFEF9F51F0C65B7E190EF311D5B01D086014542CD13B04BEF1173EAAC0F07B8"
     iex> String.length(token)
     217

  ```

  """
  @spec create_token(struct(), list()) :: String.t()
  def create_token(%TokenData{} = data, options) when is_list(options) do
    Secret.sign(data, options)
  end

  @doc """
  Get the data from a valid token.

  ## Examples

  ```elixir

     iex> alias ResuelveAuth.TokenData
     iex> timestamp = DateTime.to_unix(DateTime.utc_now(), :millisecond)
     iex> data = %TokenData{ \
     meta: nil, \
     role: "service", \
     service: "my-api", \
     session: nil, \
     timestamp: timestamp \
     }
     iex> options = [secret: "secret", limit_time: 4]
     iex> alias ResuelveAuth.Helpers.TokenHelper
     iex> token = TokenHelper.create_token(data, options)
     iex> {:ok, result} = TokenHelper.verify_token(token, options)
     iex> result["timestamp"] == data.timestamp
     true
     iex> result["service"] == data.service
     true

  ```

  """
  @spec verify_token(String.t(), list()) :: tuple()
  def verify_token(token, options) do
    with {:ok, data} <- TokenData.cast(token, options[:secret]) do
      data
      |> Secret.decode64()
      |> Secret.decode()
      |> extract()
      |> is_expired(options[:limit_time])
    end
  end

  @doc """
  Extrae la fecha de un mapa en el formato `{:ok, %{}}` esperando que
  sea un formato de unix y convertirlo a fecha.

  ## Ejemplos:

  ```elixir

  iex> timestamp = 1583797948623
  iex> data = %{"timestamp" => timestamp, "otra_llave" => "algo"}
  iex> parameter = {:ok, data}
  iex> {:ok, data} = ResuelveAuth.Helpers.TokenHelper.extract(parameter)
  iex> Map.keys(data)
  ["otra_llave", "time", "timestamp"]

  ```

  """
  def extract({:ok, %{"timestamp" => timestamp} = data}) do
    with {:ok, time} <- Calendar.from_unix(timestamp) do
      {:ok, Map.merge(data, %{"time" => time})}
    end
  end

  def extract({:error, reason}) do
    Logger.error("while deconding: #{inspect(reason)}")
    {:error, :unauthorized}
  end

  @doc """
  Define if token is expired.
  """
  @spec is_expired({:error, atom()} | {:ok, binary()}, integer()) ::
          {:ok, map()} | {:error, atom()}
  def is_expired({:error, _reason} = error, _time), do: error

  def is_expired({:ok, %{"time" => time} = data}, limit_time) do
    DateTime.utc_now()
    |> Calendar.diff(time)
    |> is_expired(limit_time)
    |> case do
      true -> {:error, :expired}
      false -> {:ok, data}
    end
  end

  @doc """
  Identify if the time is less than the time limit

  ## Ejemplo:

  ```elixir

  iex> ResuelveAuth.Helpers.TokenHelper.is_expired(4, 5)
  false

  iex> ResuelveAuth.Helpers.TokenHelper.is_expired(4, 4)
  false

  iex> ResuelveAuth.Helpers.TokenHelper.is_expired(5, 4)
  true

  ```
  """
  @spec is_expired(integer(), integer()) :: boolean()
  def is_expired(time, limit_time), do: time > limit_time
end

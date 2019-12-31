defmodule ResuelveAuth.Helpers.TokenHelper do
  @moduledoc """
  Modulo para la generacion y verificacion de tokens JWT
  """

  require Logger
  alias ResuelveAuth.TokenData
  alias ResuelveAuth.Utils.Calendar
  alias ResuelveAuth.Utils.Secret

  @doc """
  Genera un token usando un mapa. Retorna un token con el siguiente formato
  JSON_EN_BASE64_SEGURO_PARA_URLS.FIRMA_HMAC_SHA_256_EN_BASE_16

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
     iex> secret = "secret"
     iex> alias ResuelveAuth.Helpers.TokenHelper
     iex> token = TokenHelper.create_token(data, secret)
     "eyJ0aW1lc3RhbXAiOjE1NzI2NTYxNTUxMzUsInNlc3Npb24iOm51bGwsInNlcnZpY2UiOiJteS1hcGkiLCJyb2xlIjoic2VydmljZSIsIm1ldGEiOm51bGx9.1E1FA5A03B62DB5E0E5C5627D578E4ABBD1E83EFBFF72907428D0C95DC491394"
     iex> String.length(token)
     185

  ```

  """
  @spec create_token(struct, String.t()) :: String.t()
  def create_token(%TokenData{} = data, secret) when is_map(data) do
    Logger.debug("Token data: #{inspect(data)}")
    Secret.sign(data, secret)
  end

  @doc """
  Verifica si el token es válido y devuelve una mapa con los datos del token.

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
     iex> token = TokenHelper.create_token(data, options[:secret])
     iex> {:ok, result} = TokenHelper.verify_token(token, options)
     iex> result["timestamp"] == data.timestamp
     true
     iex> result["service"] == data.service
     true

  ```

  """
  @spec verify_token(String.t(), List.t()) :: tuple
  def verify_token(token, options) do
    with {:ok, data} <- TokenData.cast(token, options[:secret]) do
      data
      |> Secret.decode64()
      |> Secret.decode()
      |> extract()
      |> is_expired(options[:limit_time])
    end
  end

  def extract({:ok, %{"timestamp" => timestamp} = data}) do
    with {:ok, time} <- Calendar.from_unix(timestamp) do
      {:ok, Map.merge(data, %{"time" => time})}
    end
  end

  def extract({:error, reason}) do
    Logger.error("while deconding: #{inspect(reason)}")
    {:error, :unauthorized}
  end

  # Evalua si ha expirado la sesión siempre y cuando el valor
  # de entrada sea una tupla con respuesta positiva {:ok, data}
  @spec is_expired({:error, any()} | {:ok, binary()}, integer()) ::
          {:ok, binary()} | {:error, binary()}
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
  Identifica si el tiempo resultante (primer parámetro) es menor o igual al tiempo
  límite (segundo parámetro).

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

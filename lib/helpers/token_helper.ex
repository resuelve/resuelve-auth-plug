defmodule ResuelveAuth.Helpers.TokenHelper do
  @moduledoc """
  Modulo para la generacion y verificacion de tokens JWT
  """

  alias ResuelveAuth.TokenData
  alias ResuelveAuth.Utils.Calendar
  alias ResuelveAuth.Utils.Secret

  @error "Unauthorized"
  @limit_time 4

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
     iex> secret = "secret"
     iex> alias ResuelveAuth.Helpers.TokenHelper
     iex> token = TokenHelper.create_token(data, secret)
     iex> {:ok, result} = TokenHelper.verify_token(token, secret)
     iex> result["timestamp"] == data.timestamp
     true
     iex> result["service"] == data.service
     true

  ```

  """
  @spec verify_token(String.t(), String.t()) :: tuple
  def verify_token(token, secret) do
    with {:ok, data} <- TokenData.cast(token, secret) do
      data
      |> Secret.decode64()
      |> Secret.decode()
      |> is_expired()
    end
  end

  # Evalua si ha expirado la sesión siempre y cuando el valor
  # de entrada sea una tupla con respuesta positiva {:ok, data}
  @spec is_expired({:error, any()} | {:ok, binary()}) ::
          {:ok, binary()} | {:error, binary()}
  defp is_expired({:error, _}), do: {:error, @error}

  defp is_expired({:ok, data}) do
    data
    |> Map.get("timestamp")
    |> Calendar.add(@limit_time, :hour)
    |> Calendar.is_past?()
    |> case do
      true -> {:error, @error}
      false -> {:ok, data}
    end
  end
end

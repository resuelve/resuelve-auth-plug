defmodule ResuelveAuth.Helpers.TokenHelper do
  @moduledoc """
  Modulo para la generacion y verificacion de tokens JWT
  """

  require Logger
  alias ResuelveAuth.Helpers.TokenData
  alias ResuelveAuth.Utils.Calendar
  @error "Unauthorized"

  @doc """
  Genera un token usando un mapa. Retorna un token con el siguiente formato
  JSON_EN_BASE64_SEGURO_PARA_URLS.FIRMA_HMAC_SHA_256_EN_BASE_16
  """
  @spec create_token(struct, String.t()) :: String.t()
  def create_token(%TokenData{} = data, secret) when is_map(data) do
    no_logs() || Logger.debug("Token data: #{inspect(data)}")

    case Poison.encode(data) do
      {:ok, json} ->
        json
        |> Base.url_encode64()
        |> build_token(secret)

      {:error, reason} ->
        Logger.error("No se puede crear Token: #{reason}")
    end
  end

  @doc """
  Verifica la firma y devuelve una mapa con los datos del token
  """
  @spec verify_token(String.t(), String.t()) :: tuple
  def verify_token(token, secret) do
    case String.contains?(token, ".") do
      true -> verify_token(token, secret, :ok)
      false -> {:error, @error}
    end
  end

  def verify_token(token, secret, :ok) do
    [data, sign] = String.split(token, ".")

    secret
    |> sign_data(data, sign)
    |> equivalent?()
    |> parse_token_data()
    |> expired?()
    |> response()
  end

  def sign_data(secret, data, sign) do
    valid_sign = sign_data(secret, data)
    %{data: data, valid_sign: valid_sign, sign: sign}
  end

  def sign_data(secret, data) do
    Base.encode16(:crypto.hmac(:sha256, secret, data))
  end

  def equivalent?(%{data: data, valid_sign: valid_sign, sign: sign}) do
    if String.equivalent?(valid_sign, sign) do
      {:ok, data}
    else
      {:error, false}
    end
  end

  def expired?({:error, _}), do: {:error, @error}

  def expired?({:ok, data}) do
    expired =
      data
      |> Map.get("timestamp")
      |> Calendar.is_past?()

    %{expired: expired, data: data}
  end

  def response(%{expired: true, data: _}), do: {:error, @error}
  def response(%{expired: false, data: data}), do: {:ok, data}
  def response({:error, message}), do: {:error, message}

  def parse_token_data({:error, message}), do: {:error, message}

  def parse_token_data({:ok, data}) do
    {:ok, json} = Base.url_decode64(data)
    Poison.decode(json)
  end

  defp build_token(encoded_json, secret) do
    sign = sign_data(secret, encoded_json)
    "#{encoded_json}.#{sign}"
  end

  defp no_logs, do: Application.get_env(:resuelve_auth, :no_logs)
end

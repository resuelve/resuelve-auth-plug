defmodule ResuelveAuth.Helpers.TokenHelper do
  @moduledoc """
  Modulo para la generacion y verificacion de tokens JWT
  """

  require Logger
  alias ResuelveAuth.Helpers.TokenData

  @doc """
  Genera un token usando un mapa. Retorna un token con el siguiente formato
  JSON_EN_BASE64_SEGURO_PARA_URLS.FIRMA_HMAC_SHA_256_EN_BASE_16
  """
  @spec create_token(struct, String.t) :: String.t
  def create_token(%TokenData{} = data, secret) when is_map(data) do

    no_logs() || Logger.debug "Token data: #{inspect data}"

    case Poison.encode(data) do
      {:ok, json} ->
        json
        |> Base.url_encode64
        |> build_token(secret)
      {:error, reason} ->
        Logger.error "No se puede crear Token: #{reason}"
    end
  end

  @doc """
  Verifica la firma y devuelve una mapa con los datos del token
  """
  @spec verify_token(String.t, String.t) :: tuple
  def verify_token(token, secret) do
    with [data, sign] <- String.split(token, "."),
         true <- String.equivalent?(sign, sign_data(data, secret)) do
      parse_token_data(data)
    else
      _ -> {:error, "Unauthorized"}
    end
  end

  defp parse_token_data(data) do
    {:ok, json} = Base.url_decode64(data)
    Poison.decode(json)
  end

  defp build_token(encoded_json, secret) do
    sign = sign_data(encoded_json, secret)
    "#{encoded_json}.#{sign}"
  end

  defp sign_data(data, secret) do
    Base.encode16(:crypto.hmac(:sha256, secret, data))
  end

  defp no_logs, do: Application.get_env(:resuelve_auth, :no_logs)
end

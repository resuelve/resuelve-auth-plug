defmodule ResuelveAuth.Helpers.TokenHelperTest do
  @moduledoc """
  Se encarga de probar el módulo TokenHelper
  """
  use ExUnit.Case
  doctest ResuelveAuth.Helpers.TokenHelper

  alias ResuelveAuth.Helpers.TokenHelper
  alias ResuelveAuth.TokenData

  @secret "secret"
  @options [secret: @secret, limit_time: 4]
  @json "eyJ0aW1lc3RhbXAiOiJ0aW1lc3RhbXAiLCJzZXNzaW9uIjoic2Vzc2lvbiIsInNlcnZpY2UiOiJteV9zZXJ2aWNlIiwicm9sZSI6InJvbGUiLCJtZXRhIjoibWV0YWRhdGEifQ==."
  @sign "B5DCF6F8352BEC7D59C521E29A10122EA79456C76394F104F05B6B8203DB4F4E"

  test "Generate new token" do
    token_data = %TokenData{
      service: "my_service",
      role: "role",
      session: "session",
      timestamp: "timestamp",
      meta: "metadata"
    }

    assert TokenHelper.create_token(token_data, @secret) == @json <> @sign
  end

  test "Validate token after build it" do
    timestamp = DateTime.to_unix(DateTime.utc_now(), :millisecond)

    token_data = %TokenData{
      service: "my_service",
      role: "role",
      session: "session",
      timestamp: timestamp,
      meta: "metadata"
    }

    token = TokenHelper.create_token(token_data, @secret)
    assert {:ok, data} = TokenHelper.verify_token(token, @options)
    assert data = token_data
  end

  test "Verify token when timestamp is wrong" do
    token = @json <> @sign
    result = TokenHelper.verify_token(token, @options)
    assert result == {:error, :invalid_unix_time}
  end

  test "Verify invalid token (no dot into string)" do
    result = TokenHelper.verify_token("invalid_token", @options)
    assert result == {:error, :wrong_format}
  end
end

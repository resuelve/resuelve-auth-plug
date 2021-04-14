defmodule ResuelveAuth.Helpers.TokenHelperTest do
  @moduledoc """
  Testing the TokenHelper module
  """
  use ExUnit.Case
  doctest ResuelveAuth.Helpers.TokenHelper

  alias ResuelveAuth.Helpers.TokenHelper
  alias ResuelveAuth.TokenData

  @secret [secret: "secret", limit_time: 4]
  @token "eyJ0aW1lc3RhbXAiOiJ0aW1lc3RhbXAiLCJzZXNzaW9uIjoic2Vzc2lvbiIsInNlcnZpY2UiOiJteV9zZXJ2aWNlIiwicm9sZSI6InJvbGUiLCJtZXRhIjoibWV0YWRhdGEiLCJleHBpcmF0aW9uIjo4NjQwMDAwMH0=.876C688998BACBC78FBAF6821AB579ACB8A8A8FCD906BC833CC438D19DD0B5EA"

  test "generate new token" do
    token_data = %TokenData{
      service: "my_service",
      role: "role",
      session: "session",
      timestamp: "timestamp",
      meta: "metadata"
    }

    assert TokenHelper.create_token(token_data, @secret) == @token
  end

  test "validate token after build it" do
    timestamp = DateTime.to_unix(DateTime.utc_now(), :millisecond)

    token_data = %TokenData{
      service: "my_service",
      role: "role",
      session: "session",
      timestamp: timestamp,
      meta: "metadata"
    }

    token = TokenHelper.create_token(token_data, @secret)
    assert {:ok, data} = TokenHelper.verify_token(token, @secret)
    assert data = token_data
  end

  test "verify token when timestamp is string" do
    result = TokenHelper.verify_token(@token, @secret)
    assert {:error, :invalid_unix_time} == result
  end

  test "verify invalid token (no dot into string)" do
    result = TokenHelper.verify_token("invalid_token", @secret)
    assert {:error, :wrong_format} == result
  end
end

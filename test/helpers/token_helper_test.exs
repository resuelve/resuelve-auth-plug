defmodule ResuelveAuth.Helpers.TokenHelperTest do
  @moduledoc """
  Testing the TokenHelper module
  """
  use ExUnit.Case
  doctest ResuelveAuth.Helpers.TokenHelper

  alias ResuelveAuth.Helpers.TokenHelper
  alias ResuelveAuth.TokenData

  @secret [secret: "secret", limit_time: 4]
  @token "eyJleHBpcmF0aW9uIjo4NjQwMDAwMCwic2Vzc2lvbiI6InNlc3Npb24iLCJyb2xlIjoicm9sZSIsInNlcnZpY2UiOiJteV9zZXJ2aWNlIiwidGltZXN0YW1wIjoidGltZXN0YW1wIiwibWV0YSI6Im1ldGFkYXRhIn0=.231C4E2CBF47C28E3A90E32EC8CB9B43C173A3CD572C5D17FD5015F0C2F7E47B"

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
    assert data
      |> Map.new(fn {k, v} -> {String.to_atom(k), v} end)
      |> Map.take(Map.keys(token_data))
      |> Map.equal?(Map.from_struct(token_data))
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

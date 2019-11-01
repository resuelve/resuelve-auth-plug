defmodule ResuelveAuth.Helpers.TokenHelperTest do
  @moduledoc """
  Se encarga de probar el módulo TokenHelper
  """
  use ExUnit.Case
  alias ResuelveAuth.Helpers.TokenHelper
  alias ResuelveAuth.Helpers.TokenData

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

    assert TokenHelper.create_token(token_data, "secret") == @json <> @sign
  end

  test "Verify token when timestamp is string" do
    result = TokenHelper.verify_token(@json <> @sign, "secret")
    assert result == {:error, "Unauthorized"}
  end

  test "Verify invalid token (no dot into string)" do
    assert TokenHelper.verify_token("invalid_token", "secret") ==
             {:error, "Unauthorized"}
  end
end

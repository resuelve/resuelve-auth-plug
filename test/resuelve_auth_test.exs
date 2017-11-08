defmodule ResuelveAuthTest do
  use ExUnit.Case
  alias ResuelveAuth.Helpers.TokenHelper
  alias ResuelveAuth.Helpers.TokenData

  @token "eyJ0aW1lc3RhbXAiOiJ0aW1lc3RhbXAiLCJzZXNzaW9uIjoic2Vzc2lvbiIsInJvbGUiOiJyb2xlIiwibWV0YSI6Im1ldGFkYXRhIn0=.C50004F5D0FE64E06C03200258A96447543925AFE7D8FDC1684D5A275E1E3E30"

  test "generate new token" do
    token_data = %TokenData{
      role: "role",
      session: "session",
      timestamp: "timestamp",
      meta: "metadata"
    }
    assert TokenHelper.create_token(token_data, "secret") == @token
  end

  test "verify token" do
    assert TokenHelper.verify_token(@token, "secret") == {
      :ok,
      %{
        "meta" => "metadata",
        "role" => "role",
        "session" => "session",
        "timestamp" => "timestamp"}}
  end
end

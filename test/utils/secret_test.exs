defmodule ResuelveAuth.Utils.SecretTest do
  use ExUnit.Case

  doctest ResuelveAuth.Utils.Secret
  alias ResuelveAuth.Utils.Secret

  @token %ResuelveAuth.TokenData{
    meta: "metadata",
    role: "user",
    service: "my-api",
    session: nil,
    timestamp: 1_594_039_006_911,
    expiration: 86_400_000
  }

  describe "[encode] " do
    test "test valid results" do
      {:ok, result} = Secret.encode(@token)

      assert result ==
        ~s({"expiration":86400000,"session":null,"role":"user","service":"my-api","timestamp":1594039006911,"meta":"metadata"})
    end

    test "test valid results with encode64" do
      result =
        @token
        |> Secret.encode()
        |> Secret.encode64()

      assert result ==
        "eyJleHBpcmF0aW9uIjo4NjQwMDAwMCwic2Vzc2lvbiI6bnVsbCwicm9sZSI6InVzZXIiLCJzZXJ2aWNlIjoibXktYXBpIiwidGltZXN0YW1wIjoxNTk0MDM5MDA2OTExLCJtZXRhIjoibWV0YWRhdGEifQ=="
    end

    test "test invalid keys" do
      data = %{:foo => "foo1", "foo" => "foo2"}
      result = Secret.encode(data)
      assert {:error, %Poison.EncodeError{message: "duplicate key found: :foo"}} = result
    end

    test "test invalid keys with encode64" do
      result =
        %{:foo => "foo1", "foo" => "foo2"}
        |> Secret.encode()
        |> Secret.encode64()

      assert {:error, %Poison.EncodeError{message: "duplicate key found: :foo"}} = result
    end
  end
end

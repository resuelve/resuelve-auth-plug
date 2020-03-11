defmodule ResuelveAuth.AuthPlugTest do
  use ExUnit.Case

  use Plug.Test
  alias ResuelveAuth.AuthPlug
  alias ResuelveAuth.Helpers.TokenHelper
  alias ResuelveAuth.TokenData

  @options [secret: "secret", limit_time: 4]

  def build_token(service) do
    token = %TokenData{
      service: service,
      role: "service",
      meta: "metadata",
      timestamp: DateTime.to_unix(DateTime.utc_now(), :millisecond)
    }

    jwt = TokenHelper.create_token(token, @options)
    %{token: token, jwt: jwt}
  end

  def cast(response) do
    for {key, val} <- response, into: %{}, do: {String.to_atom(key), val}
  end

  test "access granted" do
    %{token: token, jwt: jwt} = build_token("AuthPlugTest_App")
    options = AuthPlug.init(@options)

    conn =
      conn(:get, "/", "")
      |> put_req_header("accept", "application/json")
      |> put_req_header("authorization", "#{jwt}")
      |> AuthPlug.call(options)

    %{assigns: %{session: response}} = conn
    token_map = Map.from_struct(token)

    response_map =
      response
      |> cast()
      |> Map.delete(:time)

    assert token_map == response_map
  end

  test "bad header" do
    options = [limit_time: 4, handler: ResuelveAuth.Sample.AuthHandler]

    %{resp_body: body} =
      conn(:get, "/", "")
      |> put_req_header("accept", "application/json")
      |> put_req_header("authorization", "invalid")
      |> AuthPlug.call(options)

    assert body == ~s({"errors":{"detail":"wrong format"},"data":null})
  end
end

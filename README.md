[![Build Status](https://travis-ci.org/resuelve/resuelve-auth-plug.svg?branch=master)](https://travis-ci.org/resuelve/resuelve-auth-plug)
[![Coverage Status](https://coveralls.io/repos/github/resuelve/resuelve-auth-plug/badge.svg?branch=master)](https://coveralls.io/github/resuelve/resuelve-auth-plug?branch=master)

# ResuelveAuth

Plug to validate signed request.

## CONTENT

* [Usage](#usage)
* [Secret generation](#secret-generation)
* [Crear token y validarlo](#create-token)
* [Errors](#errors)
  - [Error handler](#error-handler)
* [Contributors](#contributors)

## Usage

```elixir
def deps do
  [{:resuelve_auth, "~> 1.5"}]
end
```

Add the plugin to a pipeline, following the [guides to creating libraries in Elixir] (https://hexdocs.pm/elixir/master/library-guidelines.html), the options are configured and can be sent to the plugin.

```elixir
pipeline :api_auth do
  ...
  options = [
    secret: "secret", 
  	 limit_time: 4,
  	 handler: MyApp.AuthHandler
  ]
  plug ResuelveAuth.AuthPlug, options
end
```

## Secret generation

When you use Phoenix you can create a new secret with:

```terminal
$> mix phx.gen.secret 32
TICxDq3wquPi49UuMfA4PjnWpz1PqnB1

$> mix phx.gen.secret 64
b9sq3yGrwWKXxpNfx3+a8hEaRa3S5QWMiRg+gPpbzc54ZpjVaqDYD3DRbPuYx621

```

Another way to create a secret is:

```terminal
$> date +%s | sha256sum | base64 | head -c 32 ; echo
MGYwM2M1Njk1MGIxYjcyOGY3OTc0ZDk0

$> date +%s | sha256sum | base64 | head -c 64 ; echo
ZGZhMzZhOWQyZTViOWQxNWIyY2NlMGExMDVhMzQ1ZGNkODA1YWUxNmRmMWRjMGZi

```

And the last if you wish to use openssl

```elixir
$> openssl rand -base64 32
//ZE5siYI04Bp/2JtFq3uJOpS4XXChADe8b9RHenzFY=

$> openssl rand -base64 64
qlTw8sjiavcPAKIHJbO/zOUqLCS99zmyerjnoRc6FumLIc/Q9K9TjitS4JmTFh5r
3ULjJAMfkouTR1OUV4LZ4Q==

```

## Create new token

When you need to use the token struct, `%TokenData{}` is the option. So, you can define your struct as:

```elixir
%TokenData{
  service: service,
  role: "service",
  meta: "metadata",
  timestamp: 1593731494361
}
```

As you can see the timestamp field requires a Unix time number. Then timestamp could be created with:

```elixir
DateTime.to_unix(DateTime.utc_now(), :millisecond)
```

And your struct looks like:

```elixir
%TokenData{
  service: "my-api",
  role: "admin",
  meta: "metadata",
  timestamp: DateTime.to_unix(DateTime.utc_now(), :millisecond)
}
```

When you create the token the function require some options.

| Option  | Description | Default value |
| ------- | ----------- | ------------- |
| limit_time | time in hours | 168 h (1 w) |
| secret  | Secret key | empty  |
| handler | Error handler function | ResuelveAuth.Sample.AuthHandler |


```elixir
iex> alias ResuelveAuth.TokenData
iex> alias ResuelveAuth.Helpers.TokenHelper
iex> time = DateTime.to_unix(DateTime.utc_now(), :millisecond)
iex> token_data = %TokenData{
      service: "my-api",
      role: "admin",
      meta: "metadata",
      timestamp: time
    }
iex> options = [secret: "super-secret-key", limit_time: 4]
iex> token = TokenHelper.create_token(token_data, options)
"eyJ0aW1lc3RhbXAiOjE1OTM3MzQ0MzQ4ODEsInNlc3Npb24iOm51bGwsInNlcnZpY2UiOiJteS1hcGkiLCJyb2xlIjoiYWRtaW4iLCJtZXRhIjoibWV0YWRhdGEifQ==.9AAEBDB040BFB22160B4628EC45D69C3546C0775398D7B03C113C5BDDEC3A74B"

```

After the token was created you can use it in your requests and validate with the follow method:

```elixir
iex> options = [secret: "super-secret-key", limit_time: 4]
iex> {:ok, result} = TokenHelper.verify_token(token, options)
{:ok,
 %{
   "meta" => "metadata",
   "role" => "admin",
   "service" => "my-api",
   "session" => nil,
   "time" => ~U[2020-07-03 00:00:34.881Z],
   "timestamp" => 1593734434881
 }}
```

If the token is invalid, you may see an error like this:

```elixir
** (MatchError) no match of right hand side value: {:error, :wrong_format}
```

## Errors

The following are the errors returned by the plug:

* `{:error, :expired}`
* `{:error, :unauthorized}`
* `{:error, :wrong_format}`

### Error handler

Maybe you want to handle each error message or improve some details in the response. Below is an example of how to customize error handling.

```elixir
defmodule App.MyErrorHandler do
  def errors(conn, reason) do
    # Error handler logic
  end
end

iex> options = [secret: "super-secret-key", limit_time: 4, handler: Module.Handler]
iex> token = TokenHelper.verify_token(token, options)
```

`verify_token` function should not call directly, this function is used as a sample. Here is an example of the [ResuelveAuth.Sample.AuthHandler](lib/sample/auth_handler.ex) module.

```elixir
  @spec errors(map, String.t()) :: any
  def errors(conn, message) do
    Logger.error(fn -> "Invalid token: #{inspect(message)}" end)
    detail = reason(message)
    response = Poison.encode!(%{data: nil, errors: %{detail: detail}})

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(:unauthorized, response)
    |> halt
  end
```

## Contributors

This is the list of [contributors](https://github.com/resuelve/resuelve-auth-plug/graphs/contributors) who have participated in this project.


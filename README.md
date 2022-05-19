[![Build Status](https://travis-ci.org/resuelve/resuelve-auth-plug.svg?branch=master)](https://travis-ci.org/resuelve/resuelve-auth-plug)
[![Coverage Status](https://coveralls.io/repos/github/resuelve/resuelve-auth-plug/badge.svg?branch=master)](https://coveralls.io/github/resuelve/resuelve-auth-plug?branch=master)
[![Issues][issues-shield]][issues-url]
[![Contributors][contributors-shield]][contributors-url]


# ResuelveAuth

Plug to validate signed request.

## Table of Contents

- [Basic Usage](#basic-usage)
- [Requeriments](#requeriments)
- [Configuration](#configuration)
  - [Config Files](#config-files)
  - [Inline Options](#inline-options)
- [Secret generation](#secret-generation)
- [Create new token data](#create-new-token-data)
- [Errors](#errors)
  - [Error handler](#error-handler)
- [Contributors](#contributors)

## Basic Usage

```elixir
def deps do
  [{:resuelve_auth, "~> 1.5", organization: "resuelve"}]
end
```

Add the plugin to a pipeline, following the [guides to creating libraries in Elixir](https://hexdocs.pm/elixir/master/library-guidelines.html).

```elixir
pipeline :api_auth do
  ...
  plug ResuelveAuth.AuthPlug
end
```

## Requirements

This library requires OTP >= 21.0

We recommend using [asdf](https://github.com/asdf-vm/asdf). Then you can install and use the correct versions simply by running:

```bash
$ asdf install
```

## Configuration

Here's the list of options that can be configured for the plug.

| Option  | Description | Default value |
| ------- | ----------- | ------------- |
| limit_time | Token lifespan in hours | 168 (1 week) |
| secret  | Secret key | empty  |
| handler | Error handler module | ResuelveAuth.Sample.AuthHandler |

### Config Files

You can declare global or per environment configuration for the plug in your config files.

```elixir
# In config/{config|prod|dev|test|runtime}.exs
config :resuelve_auth,
  secret: "my-secret-key",
  limit_time: 24,
  handler: MyApp.MyAuthHandler
```

### Inline Options

You can also pass a keyword list of options to the plug declaration. This allows
to have multiple configurations.

```elixir
  pipeline :auth do
    plug ResuelveAuth.AuthPlug, secret: "my-secret-key", ...
  end
```

Note: If you use environmental variables to set any inline configuration option,
you'll need to make sure those variables are available at compilation time since
they'll be used in a macro (your app's router). If you don't need multiple configs
per environment we recommend using `config/runtime.exs` file instead.

Inline configuration will override global and per-environment configuration.

## Secret generation

By using Phoenix you can create a new secret with:

```bash
$ mix phx.gen.secret 32
TICxDq3wquPi49UuMfA4PjnWpz1PqnB1

$ mix phx.gen.secret 64
b9sq3yGrwWKXxpNfx3+a8hEaRa3S5QWMiRg+gPpbzc54ZpjVaqDYD3DRbPuYx621
```

Another way to create a secret is:

```bash
$ date +%s | sha256sum | base64 | head -c 32 ; echo
MGYwM2M1Njk1MGIxYjcyOGY3OTc0ZDk0

$ date +%s | sha256sum | base64 | head -c 64 ; echo
ZGZhMzZhOWQyZTViOWQxNWIyY2NlMGExMDVhMzQ1ZGNkODA1YWUxNmRmMWRjMGZi
```

And in case you wish to use openssl:

```bash
$ openssl rand -base64 32
//ZE5siYI04Bp/2JtFq3uJOpS4XXChADe8b9RHenzFY=

$ openssl rand -base64 64
qlTw8sjiavcPAKIHJbO/zOUqLCS99zmyerjnoRc6FumLIc/Q9K9TjitS4JmTFh5r
3ULjJAMfkouTR1OUV4LZ4Q==
```

## Create new token data

`%TokenData{}` is the struct you'll be using to generated tokens. This is how it'd look:

```elixir
%TokenData{
  service: "service-name",
  role: "role-name",
  meta: "metadata",
  timestamp: 1593731494361
}
```

As you can see, the timestamp field requires an Unix time number, which could be created with:

```elixir
DateTime.to_unix(DateTime.utc_now(), :millisecond)
```

Your struct would actually look like this:

```elixir
%TokenData{
  service: "my-api",
  role: "admin",
  meta: "metadata",
  timestamp: DateTime.to_unix(DateTime.utc_now(), :millisecond)
}
```

This is how you can generate a token (minimum code example):

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

After creating the token you can use it in your requests and validate with the following method:

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

If the token is invalid, you will see an error like this:

```elixir
** (MatchError) no match of right hand side value: {:error, :wrong_format}
```

## Errors

The following are the errors returned by the plug:

* `{:error, :expired}`
* `{:error, :unauthorized}`
* `{:error, :wrong_format}`
* `{:error, :invalid_unix_time}`

### Error handler

Maybe you want to handle error messages differently or add details in the response. Below is an example of how to customize error handling.

```elixir
defmodule App.MyErrorHandler do
  def errors(conn, reason) do
    # Error handler logic
  end
end

iex> options = [secret: "super-secret-key", limit_time: 4, handler: App.MyErrorHandler]
iex> {:ok, result} = TokenHelper.verify_token(token, options)
```

NOTE: `verify_token` function is NOT intended to be called directly since it's used internally by the plug; its usage in these examples is for demonstration purposes only.

Take a look to the [ResuelveAuth.Sample.AuthHandler](lib/sample/auth_handler.ex) module for the default error handler implementation.

## Contributors

This is the list of [contributors](https://github.com/resuelve/resuelve-auth-plug/graphs/contributors) who have participated in this project.

[issues-shield]: https://img.shields.io/github/issues/resuelve/resuelve-auth-plug.svg?style=flat-square
[issues-url]: https://github.com/resuelve/resuelve-auth-plug/issues
[contributors-shield]: https://img.shields.io/github/contributors/resuelve/resuelve-auth-plug.svg?style=flat-square
[contributors-url]: https://github.com/resuelve/resuelve-auth-plug/graphs/contributors

# Changelog

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [v1.4] - (2020-07-06)

#### :boom: Changed

* Update documentation to English language
* Add secret tests

## [v1.3] - (2020-03-12)

#### :boom: Changed

* Plug modules are documented
* Added error handling
* Timex dependency is removed
* Unit tests are added
* Changes are made to follow the [library guidelines in Elixir] (https://hexdocs.pm/elixir/master/library-guidelines.html).

### Using this version

Add to the project

```elixir
def deps do
  [{:resuelve_auth, "~> 1.3"}]
end
```

Adding the plug

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


## [v1.2.1] - (2020-03-09)

#### :boom: Refactor

* Add token validation time.
* Add continuous integration with travis.
* Registered in hexdocs.pm

### Using this version

Add to the project

```elixir
def deps do
  [ {:resuelve_auth, "~> 1.2.1"}]
end
```

Adding the plug

```elixir
pipeline :api_auth do
  ...
  plug ResuelveAuth.Plugs.TokenAuth, "my-api"
end
```

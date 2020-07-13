defmodule ResuelveAuth.Mixfile do
  use Mix.Project

  def project do
    [
      app: :resuelve_auth,
      version: "1.2.1",
      elixir: "~> 1.5",
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger, :plug]
    ]
  end

  def description do
    "Plug de resuelve para validar peticiones firmadas"
  end

  def package do
    [
      files:
        ~w(lib mix.exs README* readme* LICENSE* license* CHAGELOG* changelog*),
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/resuelve/resuelve-auth-plug"}
    ]
  end

  defp deps do
    [
      {:plug, "~> 1.8", override: true},
      {:poison, ">= 3.1.0"}
    ]
  end
end

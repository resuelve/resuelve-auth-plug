defmodule ResuelveAuth.Mixfile do
  use Mix.Project

  @version "1.4.3"

  def project do
    [
      app: :resuelve_auth,
      version: @version,
      elixir: ">= 1.7.2",
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],
      deps: deps(),
      name: "Resuelve AuthPlug",
      source_url: "https://github.com/resuelve/resuelve-auth-plug",
      docs: docs()
    ]
  end

  def docs do
    [
      source_ref: "v#{@version}",
      main: "ResuelveAuth.AuthPlug",
      logo: "assets/logo.png",
      extras: ["README.md"]
    ]
  end

  def application do
    [
      extra_applications: [:logger, :plug]
    ]
  end

  def description do
    "Plug to validate signed requests"
  end

  def package do
    [
      files: ~w(lib mix.exs README*),
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/resuelve/resuelve-auth-plug"}
    ]
  end

  defp deps do
    [
      {:plug, "~> 1.8"},
      {:excoveralls, "~> 0.12", only: :test, override: true},
      {:ex_doc, ">= 0.19.0", runtime: false, override: true},
      {:earmark, "~> 1.3.0", override: true},
      {:credo, "~> 1.4", only: [:dev, :test], runtime: false},
      {:poison, "~> 3.1", override: true}
    ]
  end
end

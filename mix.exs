defmodule ResuelveAuth.Mixfile do
  use Mix.Project

  @version "1.4.0"

  def project do
    [
      app: :resuelve_auth,
      version: @version,
      elixir: ">= 1.7.4",
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
      markdown_processor: ExDocMakeup,
      extras: ["README.md"]
    ]
  end

  def application do
    [
      extra_applications: [:logger, :cowboy, :plug]
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
      {:cowboy, "~> 2.6"},
      {:plug, "~> 1.8"},
      {:excoveralls, "~> 0.12", only: :test},
      {:ex_doc, "~> 0.20.1", runtime: false},
      {:ex_doc_makeup, "~> 0.1.0"},
      {:poison, "~> 3.1"}
    ]
  end
end

defmodule ResuelveAuth.Mixfile do
  use Mix.Project

  def project do
    [
      app: :resuelve_auth,
      version: "2.0.0",
      elixir: ">= 1.5.2",
      start_permanent: Mix.env() == :prod,
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],
      deps: deps(),
      # Docs
      name: "Resuelve AuthPlug",
      source_url: "https://github.com/resuelve/resuelve-auth-plug",
      docs: [
        main: "ResuelveAuth.AuthPlug",
        logo: "assets/logo.png",
        markdown_processor: ExDocMakeup,
        extras: ["README.md"]
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger, :cowboy, :plug]
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

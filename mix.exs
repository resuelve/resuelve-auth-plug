defmodule ResuelveAuth.Mixfile do
  use Mix.Project

  def project do
    [
      app: :resuelve_auth,
      version: "1.3.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger, :cowboy, :plug]
    ]
  end

  defp deps do
    [
      {:cowboy, "~> 2.7"},
      {:plug, "~> 1.8"},
      {:poison, "~> 3.1"}
    ]
  end
end

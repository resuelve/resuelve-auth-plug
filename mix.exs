defmodule ResuelveAuth.Mixfile do
  use Mix.Project

  def project do
    [
      app: :resuelve_auth,
      version: "0.1.1",
      elixir: "~> 1.7.4",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger, :cowboy, :plug, :timex]
    ]
  end

  defp deps do
    [
      {:cowboy, "~> 2.6"},
      {:plug, "~> 1.8"},
      {:timex, "~> 3.5"},
      {:poison, "~> 3.1"}
    ]
  end
end

defmodule Jira.MixProject do
  use Mix.Project

  def project do
    [
      app: :jira,
      version: "0.2.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:req, "~> 0.5.4"},
      {:plug, "~> 1.18", only: :test}
    ]
  end
end

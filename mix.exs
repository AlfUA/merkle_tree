defmodule MerkleTree.MixProject do
  use Mix.Project

  def project do
    [
      app: :merkle_tree,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :crypto]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:benchee, "~> 1.0", only: [:dev, :test]}
    ]
  end
end

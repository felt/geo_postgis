defmodule GeoPostgis.Mixfile do
  use Mix.Project

  @source_url "https://github.com/bryanjos/geo_postgis"
  @version "3.4.2"

  def project do
    [
      app: :geo_postgis,
      version: @version,
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      name: "GeoPostGIS",
      deps: deps(),
      package: package(),
      docs: docs(),
      elixirc_paths: elixirc_paths(Mix.env())
    ]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:geo, "~> 3.4"},
      {:postgrex, ">= 0.0.0"},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:ecto_sql, "~> 3.0", optional: true, only: :test},
      {:poison, "~> 2.2 or ~> 3.0 or ~> 4.0 or ~> 5.0", optional: true},
      {:jason, "~> 1.2", optional: true}
    ]
  end

  defp package do
    [
      description: "PostGIS extension for Postgrex.",
      files: ["lib", "mix.exs", "README.md", "CHANGELOG.md"],
      maintainers: ["Bryan Joseph"],
      licenses: ["MIT"],
      links: %{"GitHub" => @source_url}
    ]
  end

  defp docs do
    [
      extras: ["CHANGELOG.md", "README.md"],
      main: "readme",
      source_url: @source_url,
      source_ref: "v#{@version}",
      formatters: ["html"]
    ]
  end
end

defmodule GeoPostgis.Mixfile do
  use Mix.Project

  def project do
    [
      app: :geo_postgis,
      version: "1.0.0",
      elixir: "~> 1.4",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      name: "GeoPostGIS",
      elixirc_paths: elixirc_paths(Mix.env),
      source_url: source_url()
    ]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp source_url do
    "https://github.com/bryanjos/geo_postgis"
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  defp description do
    """
    PostGIS extension for Postgrex.
    """
  end

  defp deps do
    [
      #{:geo, "~> 2.0", only: :dev},
      {:postgrex, "~> 0.13"},
      {:geo, path: "/Users/bryanjos/projects/bryanjos/geo"},
      {:ex_doc, "~> 0.14", only: :dev},
      {:ecto, "~> 2.1", optional: true, only: :test },
    ]
  end

  defp package do
    [ # These are the default files included in the package
      files: ["lib", "mix.exs", "README.md", "CHANGELOG.md"],
      maintainers: ["Bryan Joseph"],
      licenses: ["MIT"],
      links: %{ "GitHub" => source_url() }
    ]
  end
end

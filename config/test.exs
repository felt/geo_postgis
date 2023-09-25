import Config

config :geo_postgis, ecto_repos: [Geo.PostGIS.Test.Repo]

config :geo_postgis, Geo.PostGIS.Test.Repo,
  database: "geo_postgrex_test",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  types: Geo.PostGIS.PostgrexTypes

# Print only warnings and errors during test
config :logger, level: :warning

{:ok, _} = Application.ensure_all_started(:ecto_sql)

defmodule Geo.Test.Helper do
  def opts do
    [
      hostname: "localhost",
      username: "postgres",
      database: "geo_postgrex_test",
      types: Geo.PostGIS.PostgrexTypes
    ]
  end
end

ExUnit.start()

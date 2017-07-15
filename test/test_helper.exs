:ok = Application.ensure_started(:poolboy)
:ok = Application.ensure_started(:ecto)

defmodule Geo.Test.Helper do
  def opts do
    [hostname: "localhost",
     username: "postgres", database: "geo_postgrex_test",
     types: Geo.PostGIS.PostgrexTypes
    ]
  end
end

ExUnit.start()

# GeoPostGIS

[![Build & Test Status](https://github.com/felt/geo_postgis/actions/workflows/elixir-build-and-test.yml/badge.svg?branch=master)](https://github.com/felt/geo_postgis/actions/workflows/elixir-build-and-test.yml)
[![Module Version](https://img.shields.io/hexpm/v/geo_postgis.svg)](https://hex.pm/packages/geo_postgis)
[![Hex Docs](https://img.shields.io/badge/hex-docs-lightgreen.svg)](https://hexdocs.pm/geo_postgis/)
[![Total Download](https://img.shields.io/hexpm/dt/geo_postgis.svg)](https://hex.pm/packages/geo_postgis)
[![License](https://img.shields.io/hexpm/l/geo_postgis.svg)](https://github.com/felt/geo_postgis/blob/master/LICENSE)
[![Last Updated](https://img.shields.io/github/last-commit/felt/geo_postgis.svg)](https://github.com/felt/geo_postgis/commits/master)

Postgrex extension for the PostGIS data types. Uses the [geo](https://github.com/felt/geo) library

## Installation

The package can be installed by adding `:geo_postgis` to your list of
dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:geo_postgis, "~> 3.7"}
  ]
end
```

Make sure PostGIS extension to your database is installed. More information [here](https://trac.osgeo.org/postgis/wiki/UsersWikiPostGIS24UbuntuPGSQL10Apt#Install)

### Optional Configuration

```elixir
# When a binary is passed to `Geo.PostGIS.Geometry.cast/1` implementation of
# `Ecto.Type.cast/1`, it is assumed to be a GeoJSON string. When this happens,
# geo_postgis will use JSON, by default, to convert the binary to a map and
# then convert that map to one of the Geo structs. If in these cases you would
# like to use a different JSON parser, you can set the config below.

# config.exs
config :geo_postgis,
  json_library: Jason # If you want to set your JSON module
```

## Examples

Postgrex Extension for the PostGIS data types, Geometry and Geography:

```elixir
Postgrex.Types.define(MyApp.PostgresTypes, [Geo.PostGIS.Extension], [])

opts = [hostname: "localhost", username: "postgres", database: "geo_postgrex_test", types: MyApp.PostgresTypes ]
[hostname: "localhost", username: "postgres", database: "geo_postgrex_test", types: MyApp.PostgresTypes]

{:ok, pid} = Postgrex.Connection.start_link(opts)
{:ok, #PID<0.115.0>}

geo = %Geo.Point{coordinates: {30, -90}, srid: 4326}
%Geo.Point{coordinates: {30, -90}, srid: 4326}

{:ok, _} = Postgrex.Connection.query(pid, "CREATE TABLE point_test (id int, geom geometry(Point, 4326))")
{:ok, %Postgrex.Result{columns: nil, command: :create_table, num_rows: 0, rows: nil}}

{:ok, _} = Postgrex.Connection.query(pid, "INSERT INTO point_test VALUES ($1, $2)", [42, geo])
{:ok, %Postgrex.Result{columns: nil, command: :insert, num_rows: 1, rows: nil}}

Postgrex.Connection.query(pid, "SELECT * FROM point_test")
{:ok, %Postgrex.Result{columns: ["id", "geom"], command: :select, num_rows: 1,
rows: [{42, %Geo.Point{coordinates: {30.0, -90.0}, srid: 4326 }}]}}
```

Use with [Ecto](https://hexdocs.pm/ecto_sql/Ecto.Adapters.Postgres.html#module-extensions):

```elixir
# If using with Ecto, you may want something like this instead
Postgrex.Types.define(MyApp.PostgresTypes,
              [Geo.PostGIS.Extension] ++ Ecto.Adapters.Postgres.extensions(),
              json: Jason)

# Add extensions to your repo config
config :thanks, Repo,
  database: "geo_postgrex_test",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  adapter: Ecto.Adapters.Postgres,
  types: MyApp.PostgresTypes


# Create a schema
defmodule Test do
  use Ecto.Schema

  schema "test" do
    field :name,           :string
    field :geom,           Geo.PostGIS.Geometry
  end
end

# Geometry or Geography columns can also be created in migrations
defmodule Repo.Migrations.Init do
  use Ecto.Migration

  def change do
    create table(:test) do
      add :name,     :string
      add :geom,     :geometry
    end
  end
end
```

Ecto migrations can also use more elaborate [PostGIS GIS Objects](http://postgis.net/docs/using_postgis_dbmanagement.html#RefObject). These types are useful for enforcing constraints on `{Lng,Lat}` (order matters), or ensuring that a particular projection/coordinate system/format is used.

```elixir
defmodule Repo.Migrations.AdvancedInit do
  use Ecto.Migration

  def change do
    create table(:test) do
      add :name,     :string
    end
    # Add a field `lng_lat_point` with type `geometry(Point,4326)`.
    # This can store a "standard GPS" (epsg4326) coordinate pair {longitude,latitude}.
    execute("SELECT AddGeometryColumn ('test','lng_lat_point',4326,'POINT',2);", "")

    # Once a GIS data table exceeds a few thousand rows, you will want to build an index to speed up spatial searches of the data
    # Syntax - CREATE INDEX [indexname] ON [tablename] USING GIST ( [geometryfield] );
    execute("CREATE INDEX test_geom_idx ON test USING GIST (lng_lat_point);", "")
  end
end
```

Be sure to enable the PostGIS extension if you haven't already done so:

```elixir
defmodule MyApp.Repo.Migrations.EnablePostgis do
  use Ecto.Migration

  def change do
    execute "CREATE EXTENSION IF NOT EXISTS postgis", "DROP EXTENSION IF EXISTS postgis"
  end
end
```

[PostGIS functions](http://postgis.net/docs/manual-1.3/ch06.html) can also be used in Ecto queries. Currently only the OpenGIS functions are implemented. Have a look at [lib/geo_postgis.ex](lib/geo_postgis.ex) for the implemented functions. You can use them like:

```elixir
defmodule Example do
  import Ecto.Query
  import Geo.PostGIS

  def example_query(geom) do
    query = from location in Location, limit: 5, select: st_distance(location.geom, ^geom)
    query
    |> Repo.one
  end
end
```

## Development

After you got the dependencies via `mix deps.get` make sure that:

* `postgis` is installed
* your `postgres` user has the database `"geo_postgrex_test"`
* your `postgres` db user can login without a password or you set the `PGPASSWORD` environment variable appropriately

Then you can run the tests as you are used to with `mix test`.


## Copyright and License

Copyright (c) 2017 Bryan Joseph

Released under the MIT License, which can be found in the repository in [`LICENSE`](https://github.com/felt/geo_postgis/blob/master/LICENSE).

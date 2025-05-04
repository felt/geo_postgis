defmodule Geo.PostGIS.Extension do
  @moduledoc """
  PostGIS extension for Postgrex. Supports Geometry and Geography data types.

  ## Examples

  Create a new Postgrex Types module:

      Postgrex.Types.define(MyApp.PostgresTypes, [Geo.PostGIS.Extension], [])

  If using with Ecto, you may want something like thing instead:

      Postgrex.Types.define(MyApp.PostgresTypes,
                    [Geo.PostGIS.Extension] ++ Ecto.Adapters.Postgres.extensions(),
                    json: Poison)

      opts = [hostname: "localhost", username: "postgres", database: "geo_postgrex_test",
      types: MyApp.PostgresTypes ]

      [hostname: "localhost", username: "postgres", database: "geo_postgrex_test",
        types: MyApp.PostgresTypes]

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
      rows: [{42, %Geo.Point{coordinates: {30.0, -90.0}, srid: 4326}}]}}

  """

  @behaviour Postgrex.Extension

  @geo_types [
    Geo.GeometryCollection,
    Geo.LineString,
    Geo.LineStringZ,
    Geo.LineStringZM,
    Geo.MultiLineString,
    Geo.MultiLineStringZ,
    Geo.MultiLineStringZM,
    Geo.MultiPoint,
    Geo.MultiPointZ,
    Geo.MultiPolygon,
    Geo.MultiPolygonZ,
    Geo.Point,
    Geo.PointZ,
    Geo.PointM,
    Geo.PointZM,
    Geo.Polygon,
    Geo.PolygonZ
  ]

  def init(opts) do
    Keyword.get(opts, :decode_copy, :copy)
  end

  def matching(_) do
    [type: "geometry", type: "geography"]
  end

  def format(_) do
    :binary
  end

  def encode(_opts) do
    quote location: :keep do
      %x{} = geom when x in unquote(@geo_types) ->
        data = Geo.WKB.encode_to_iodata(geom)
        [<<IO.iodata_length(data)::integer-size(32)>> | data]
    end
  end

  def decode(:reference) do
    quote location: :keep do
      <<len::integer-size(32), wkb::binary-size(len)>> ->
        Geo.WKB.decode!(wkb)
    end
  end

  def decode(:copy) do
    quote location: :keep do
      <<len::integer-size(32), wkb::binary-size(len)>> ->
        Geo.WKB.decode!(:binary.copy(wkb))
    end
  end
end

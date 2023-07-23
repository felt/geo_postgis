if Code.ensure_loaded?(Ecto.Type) do
  defmodule Geo.PostGIS.Geometry do
    @moduledoc """
    Implements the Ecto.Type behaviour for all geometry types
    """

    alias Geo.{
      Point,
      PointZ,
      PointM,
      PointZM,
      LineString,
      LineStringZ,
      LineStringZM,
      Polygon,
      PolygonZ,
      MultiPoint,
      MultiPointZ,
      MultiLineString,
      MultiLineStringZ,
      MultiPolygon,
      MultiPolygonZ,
      GeometryCollection
    }

    @types [
      "Point",
      "PointZ",
      "PointM",
      "PointZM",
      "LineString",
      "LineStringZ",
      "LineStringZM",
      "Polygon",
      "PolygonZ",
      "MultiPoint",
      "MultiPointZ",
      "MultiLineString",
      "MultiLineStringZ",
      "MultiPolygon",
      "MultiPolygonZ"
    ]

    @geometries [
      Point,
      PointZ,
      PointM,
      PointZM,
      LineString,
      LineStringZ,
      LineStringZM,
      Polygon,
      PolygonZ,
      MultiPoint,
      MultiPointZ,
      MultiLineString,
      MultiLineStringZ,
      MultiPolygon,
      MultiPolygonZ,
      GeometryCollection
    ]

    if macro_exported?(Ecto.Type, :__using__, 1) do
      use Ecto.Type
    else
      @behaviour Ecto.Type
    end

    def type, do: :geometry

    def blank?(_), do: false

    def load(%struct{} = geom) when struct in @geometries, do: {:ok, geom}
    def load(_), do: :error

    def dump(%struct{} = geom) when struct in @geometries, do: {:ok, geom}
    def dump(_), do: :error

    def cast({:ok, value}), do: cast(value)

    def cast(%struct{} = geom) when struct in @geometries, do: {:ok, geom}

    def cast(%{"type" => type, "coordinates" => _} = geom) when type in @types do
      {:ok, Geo.JSON.decode!(geom)}
    end

    def cast(%{"type" => "GeometryCollection", "geometries" => _} = geom) do
      {:ok, Geo.JSON.decode!(geom)}
    end

    def cast(geom) when is_binary(geom) do
      {:ok, geom |> Geo.PostGIS.Config.json_library().decode!() |> Geo.JSON.decode!()}
    end

    def cast(_), do: :error

    def embed_as(_), do: :self

    def equal?(a, b), do: a == b
  end
end

defmodule Geo.PostGIS.GeometryCastTest do
  use ExUnit.Case, async: true
  alias Geo.PostGIS.Geometry

  describe "Geometry.cast/1" do
    test "cast from map with key => value syntax" do
      point_map = %{
        "type" => "Point",
        "coordinates" => [30.0, -90.0],
        "crs" => %{"type" => "name", "properties" => %{"name" => "EPSG:4326"}}
      }

      result = Geometry.cast(point_map)

      assert {:ok, point} = result
      assert %Geo.Point{} = point
      assert point.coordinates == {30.0, -90.0}
      assert point.srid == 4326
    end

    test "cast from map with key: value syntax" do
      point_map = %{
        type: "Point",
        coordinates: [30.0, -90.0],
        crs: %{type: "name", properties: %{name: "EPSG:4326"}}
      }

      result = Geometry.cast(point_map)

      assert {:ok, point} = result
      assert %Geo.Point{} = point
      assert point.coordinates == {30.0, -90.0}
      assert point.srid == 4326
    end

    test "cast GeometryCollection from map with key => value syntax" do
      collection_map = %{
        "type" => "GeometryCollection",
        "geometries" => [
          %{
            "type" => "Point",
            "coordinates" => [30.0, -90.0]
          },
          %{
            "type" => "LineString",
            "coordinates" => [[30.0, -30.0], [90.0, -90.0]]
          }
        ],
        "crs" => %{"type" => "name", "properties" => %{"name" => "EPSG:4326"}}
      }

      result = Geometry.cast(collection_map)

      assert {:ok, collection} = result
      assert %Geo.GeometryCollection{} = collection
      assert length(collection.geometries) == 2
      assert Enum.at(collection.geometries, 0).__struct__ == Geo.Point
      assert Enum.at(collection.geometries, 1).__struct__ == Geo.LineString
      assert collection.srid == 4326
    end

    test "cast GeometryCollection from map with key: value syntax" do
      collection_map = %{
        type: "GeometryCollection",
        geometries: [
          %{
            type: "Point",
            coordinates: [30.0, -90.0]
          },
          %{
            type: "LineString",
            coordinates: [[30.0, -30.0], [90.0, -90.0]]
          }
        ],
        crs: %{type: "name", properties: %{name: "EPSG:4326"}}
      }

      result = Geometry.cast(collection_map)

      assert {:ok, collection} = result
      assert %Geo.GeometryCollection{} = collection
      assert length(collection.geometries) == 2
      assert Enum.at(collection.geometries, 0).__struct__ == Geo.Point
      assert Enum.at(collection.geometries, 1).__struct__ == Geo.LineString
      assert collection.srid == 4326
    end
  end
end

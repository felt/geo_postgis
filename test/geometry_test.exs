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
  end
end

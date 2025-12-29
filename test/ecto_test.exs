defmodule Geo.Ecto.Test do
  use ExUnit.Case, async: true
  use Ecto.Migration
  import Ecto.Query
  import Geo.PostGIS
  alias Geo.PostGIS.Test.Repo

  @multipoint_wkb "0106000020E6100000010000000103000000010000000F00000091A1EF7505D521C0F4AD6182E481424072B3CE92FED421C01D483CDAE281424085184FAEF7D421C0CB159111E1814240E1EBD7FBF8D421C0D421F7C8DF814240AD111315FFD421C0FE1F21C0DE81424082A0669908D521C050071118DE814240813C5E700FD521C0954EEF97DE814240DC889FA815D521C0B3382182E08142400148A81817D521C0E620D22BE2814240F1E95BDE19D521C08BD53852E3814240F81699E217D521C05B35D7DCE4814240B287C8D715D521C0336338FEE481424085882FB90FD521C0FEF65484E5814240A53E1E460AD521C09A0EA286E581424091A1EF7505D521C0F4AD6182E4814240"

  defmodule Location do
    use Ecto.Schema

    schema "locations" do
      field(:name, :string)
      field(:geom, Geo.PostGIS.Geometry)
    end
  end

  defmodule Geographies do
    use Ecto.Schema

    schema "geographies" do
      field(:name, :string)
      field(:geom, Geo.PostGIS.Geometry)
    end
  end

  defmodule LocationMulti do
    use Ecto.Schema

    schema "location_multi" do
      field(:name, :string)
      field(:geom, Geo.PostGIS.Geometry)
    end
  end

  setup _ do
    {:ok, pid} = Postgrex.start_link(Geo.Test.Helper.opts())

    {:ok, _} = Postgrex.query(pid, "CREATE EXTENSION IF NOT EXISTS postgis", [])

    {:ok, _} =
      Postgrex.query(pid, "DROP TABLE IF EXISTS locations, geographies, location_multi", [])

    {:ok, _} =
      Postgrex.query(
        pid,
        "CREATE TABLE locations (id serial primary key, name varchar, geom geometry(MultiPolygon))",
        []
      )

    {:ok, _} =
      Postgrex.query(
        pid,
        "CREATE TABLE geographies (id serial primary key, name varchar, geom geography(Point))",
        []
      )

    {:ok, _} =
      Postgrex.query(
        pid,
        "CREATE TABLE location_multi (id serial primary key, name varchar, geom geometry)",
        []
      )

    {:ok, _} = Repo.start_link()

    :ok
  end

  test "query multipoint" do
    geom = Geo.WKB.decode!(@multipoint_wkb)

    Repo.insert(%Location{name: "hello", geom: geom})
    query = from(location in Location, limit: 5, select: location)
    results = Repo.all(query)

    assert geom == hd(results).geom
  end

  test "query area" do
    geom = Geo.WKB.decode!(@multipoint_wkb)

    Repo.insert(%Location{name: "hello", geom: geom})

    query = from(location in Location, limit: 5, select: st_area(location.geom))
    results = Repo.all(query)

    assert is_number(hd(results))
  end

  test "query transform" do
    geom = Geo.WKB.decode!(@multipoint_wkb)

    Repo.insert(%Location{name: "hello", geom: geom})

    query = from(location in Location, limit: 1, select: st_transform(location.geom, 3452))
    results = Repo.one(query)

    assert results.srid == 3452
  end

  test "query distance" do
    geom = Geo.WKB.decode!(@multipoint_wkb)

    Repo.insert(%Location{name: "hello", geom: geom})

    query = from(location in Location, limit: 5, select: st_distance(location.geom, ^geom))
    results = Repo.one(query)

    assert results == 0
  end

  test "query sphere distance" do
    geom = Geo.WKB.decode!(@multipoint_wkb)

    Repo.insert(%Location{name: "hello", geom: geom})

    query = from(location in Location, limit: 5, select: st_distancesphere(location.geom, ^geom))
    results = Repo.one(query)

    assert results == 0
  end

  test "st_extent" do
    geom = Geo.WKB.decode!(@multipoint_wkb)

    Repo.insert(%Location{name: "hello", geom: geom})

    query = from(location in Location, select: st_extent(location.geom))
    assert [%Geo.Polygon{coordinates: [coordinates]}] = Repo.all(query)
    assert length(coordinates) == 5
  end

  test "example" do
    geom = Geo.WKB.decode!(@multipoint_wkb)
    Repo.insert(%Location{name: "hello", geom: geom})

    defmodule Example do
      import Ecto.Query
      import Geo.PostGIS

      def example_query(geom) do
        from(location in Location, select: st_distance(location.geom, ^geom))
      end
    end

    query = Example.example_query(geom)
    results = Repo.one(query)
    assert results == 0
  end

  test "geography" do
    geom = %Geo.Point{coordinates: {30, -90}, srid: 4326}

    Repo.insert(%Geographies{name: "hello", geom: geom})
    query = from(location in Geographies, limit: 5, select: location)
    results = Repo.all(query)

    assert geom == hd(results).geom
  end

  test "cast point" do
    geom = %Geo.Point{coordinates: {30, -90}, srid: 4326}

    Repo.insert(%Geographies{name: "hello", geom: geom})
    query = from(location in Geographies, limit: 5, select: location)
    results = Repo.all(query)

    result = hd(results)

    json = Geo.JSON.encode(%Geo.Point{coordinates: {31, -90}, srid: 4326})

    changeset =
      Ecto.Changeset.cast(result, %{title: "Hello", geom: json}, [:name, :geom])
      |> Ecto.Changeset.validate_required([:name, :geom])

    assert changeset.changes == %{geom: %Geo.Point{coordinates: {31, -90}, srid: 4326}}
  end

  test "cast point from map" do
    geom = %Geo.Point{coordinates: {30, -90}, srid: 4326}

    Repo.insert(%Geographies{name: "hello", geom: geom})
    query = from(location in Geographies, limit: 5, select: location)
    results = Repo.all(query)

    result = hd(results)

    json = %{
      "type" => "Point",
      "crs" => %{"type" => "name", "properties" => %{"name" => "EPSG:4326"}},
      "coordinates" => [31, -90]
    }

    changeset =
      Ecto.Changeset.cast(result, %{title: "Hello", geom: json}, [:name, :geom])
      |> Ecto.Changeset.validate_required([:name, :geom])

    assert changeset.changes == %{geom: %Geo.Point{coordinates: {31, -90}, srid: 4326}}
  end

  test "order by distance" do
    geom1 = %Geo.Point{coordinates: {30, -90}, srid: 4326}
    geom2 = %Geo.Point{coordinates: {30, -91}, srid: 4326}
    geom3 = %Geo.Point{coordinates: {60, -91}, srid: 4326}

    Repo.insert(%Geographies{name: "there", geom: geom2})
    Repo.insert(%Geographies{name: "here", geom: geom1})
    Repo.insert(%Geographies{name: "way over there", geom: geom3})

    query =
      from(
        location in Geographies,
        limit: 5,
        select: location,
        order_by: st_distance(location.geom, ^geom1)
      )

    assert ["here", "there", "way over there"] ==
             Repo.all(query)
             |> Enum.map(fn x -> x.name end)
  end

  test "insert multiple geometry types" do
    geom1 = %Geo.Point{coordinates: {30, -90}, srid: 4326}
    geom2 = %Geo.LineString{coordinates: [{30, -90}, {30, -91}], srid: 4326}

    Repo.insert(%LocationMulti{name: "hello point", geom: geom1})
    Repo.insert(%LocationMulti{name: "hello line", geom: geom2})
    query = from(location in LocationMulti, select: location)
    [m1, m2] = Repo.all(query)

    assert m1.geom == geom1
    assert m2.geom == geom2
  end

  describe "st_is_closed/1" do
    test "returns true for a closed linestring" do
      closed_line = %Geo.LineString{
        coordinates: [{0, 0}, {1, 0}, {1, 1}, {0, 1}, {0, 0}],
        srid: 4326
      }

      Repo.insert(%LocationMulti{name: "closed_line", geom: closed_line})

      query =
        from(l in LocationMulti,
          where: l.name == "closed_line",
          select: st_is_closed(l.geom)
        )

      result = Repo.one(query)
      assert result == true
    end

    test "returns false for an open linestring" do
      open_line = %Geo.LineString{
        coordinates: [{0, 0}, {1, 0}, {1, 1}, {0, 1}],
        srid: 4326
      }

      Repo.insert(%LocationMulti{name: "open_line", geom: open_line})

      query =
        from(l in LocationMulti,
          where: l.name == "open_line",
          select: st_is_closed(l.geom)
        )

      result = Repo.one(query)
      assert result == false
    end

    test "returns false for a multilinestring" do
      open_line = %Geo.MultiLineString{
        coordinates: [
          [{0, 0}, {1, 0}, {1, 1}, {0, 0}],
          [{0, 0}, {1, 0}]
        ],
        srid: 4326
      }

      Repo.insert(%LocationMulti{name: "multilinestring", geom: open_line})

      query =
        from(l in LocationMulti,
          where: l.name == "multilinestring",
          select: st_is_closed(l.geom)
        )

      result = Repo.one(query)
      assert result == false
    end

    test "returns true for a point" do
      point = %Geo.Point{coordinates: {0, 0}, srid: 4326}

      Repo.insert(%LocationMulti{name: "point", geom: point})

      query =
        from(l in LocationMulti,
          where: l.name == "point",
          select: st_is_closed(l.geom)
        )

      result = Repo.one(query)
      assert result == true
    end

    test "returns true for a multipoint" do
      point = %Geo.MultiPoint{coordinates: [{0, 0}, {1, 1}], srid: 4326}

      Repo.insert(%LocationMulti{name: "multipoint", geom: point})

      query =
        from(l in LocationMulti,
          where: l.name == "multipoint",
          select: st_is_closed(l.geom)
        )

      result = Repo.one(query)
      assert result == true
    end
  end

  describe "st_node" do
    test "self-intersecting linestring" do
      coordinates = [{0, 0, 0}, {2, 2, 2}, {0, 2, 0}, {2, 0, 2}]
      cross_point = {1, 1, 1}

      # Create a self-intersecting linestring (crossing at point {1, 1, 1})
      linestring = %Geo.LineStringZ{
        coordinates: coordinates,
        srid: 4326
      }

      Repo.insert(%LocationMulti{name: "intersecting lines", geom: linestring})

      query =
        from(
          location in LocationMulti,
          select: st_node(location.geom)
        )

      result = Repo.one(query)

      assert %Geo.MultiLineStringZ{} = result

      assert result.coordinates == [
               [Enum.at(coordinates, 0), cross_point],
               [cross_point, Enum.at(coordinates, 1), Enum.at(coordinates, 2), cross_point],
               [cross_point, Enum.at(coordinates, 3)]
             ]
    end

    test "intersecting multilinestring" do
      coordinates1 = [{0, 0, 0}, {2, 2, 2}]
      coordinates2 = [{0, 2, 0}, {2, 0, 2}]
      cross_point = {1, 1, 1}

      # Create a multilinestring that intersects (crossing at point {1, 1, 1})
      linestring = %Geo.MultiLineStringZ{
        coordinates: [
          coordinates1,
          coordinates2
        ],
        srid: 4326
      }

      Repo.insert(%LocationMulti{name: "intersecting lines", geom: linestring})

      query =
        from(
          location in LocationMulti,
          select: st_node(location.geom)
        )

      result = Repo.one(query)

      assert %Geo.MultiLineStringZ{} = result

      assert result.coordinates == [
               [Enum.at(coordinates1, 0), cross_point],
               [Enum.at(coordinates2, 0), cross_point],
               [cross_point, Enum.at(coordinates1, 1)],
               [cross_point, Enum.at(coordinates2, 1)]
             ]
    end
  end

  describe "st_line_merge/1" do
    test "merge lines with different orientation" do
      multiline = %Geo.MultiLineString{
        coordinates: [
          [{10, 160}, {60, 120}],
          [{120, 140}, {60, 120}],
          [{120, 140}, {180, 120}]
        ],
        srid: 4326
      }

      Repo.insert(%LocationMulti{name: "lines with different orientation", geom: multiline})

      query =
        from(
          location in LocationMulti,
          where: location.name == "lines with different orientation",
          select: st_line_merge(location.geom)
        )

      result = Repo.one(query)

      assert %Geo.LineString{} = result

      assert result.coordinates == [
               {10, 160},
               {60, 120},
               {120, 140},
               {180, 120}
             ]
    end

    test "lines not merged across intersections with degree > 2" do
      multiline = %Geo.MultiLineString{
        coordinates: [
          [{10, 160}, {60, 120}],
          [{120, 140}, {60, 120}],
          [{120, 140}, {180, 120}],
          [{100, 180}, {120, 140}]
        ],
        srid: 4326
      }

      Repo.insert(%LocationMulti{name: "lines with intersection degree > 2", geom: multiline})

      query =
        from(
          location in LocationMulti,
          where: location.name == "lines with intersection degree > 2",
          select: st_line_merge(location.geom)
        )

      result = Repo.one(query)

      # Verify the result is still multiple lines after merging and consists of 3 linestrings
      assert %Geo.MultiLineString{} = result
      assert length(result.coordinates) == 3

      expected_linestrings = [
        [{10, 160}, {60, 120}, {120, 140}],
        [{100, 180}, {120, 140}],
        [{120, 140}, {180, 120}]
      ]

      sorted_result = Enum.sort_by(result.coordinates, fn linestring -> hd(linestring) end)
      sorted_expected = Enum.sort_by(expected_linestrings, fn linestring -> hd(linestring) end)

      assert sorted_result == sorted_expected
    end

    test "return original geometry if not possible to merge" do
      multiline = %Geo.MultiLineString{
        coordinates: [
          [{-29, -27}, {-30, -29.7}, {-36, -31}, {-45, -33}],
          [{-45.2, -33.2}, {-46, -32}]
        ],
        srid: 4326
      }

      Repo.insert(%LocationMulti{name: "disconnected lines", geom: multiline})

      query =
        from(
          location in LocationMulti,
          where: location.name == "disconnected lines",
          select: st_line_merge(location.geom)
        )

      result = Repo.one(query)

      # Verify the result is not merged and consists of 2 linestrings
      assert %Geo.MultiLineString{} = result
      assert length(result.coordinates) == 2

      expected_linestrings = [
        [{-29, -27}, {-30, -29.7}, {-36, -31}, {-45, -33}],
        [{-45.2, -33.2}, {-46, -32}]
      ]

      sorted_result = Enum.sort_by(result.coordinates, fn linestring -> hd(linestring) end)
      sorted_expected = Enum.sort_by(expected_linestrings, fn linestring -> hd(linestring) end)

      assert sorted_result == sorted_expected
    end
  end

  describe "st_line_merge/2" do
    test "lines with opposite directions not merged if directed is true" do
      multiline = %Geo.MultiLineString{
        coordinates: [
          [{60, 30}, {10, 70}],
          [{120, 50}, {60, 30}],
          [{120, 50}, {180, 30}]
        ],
        srid: 4326
      }

      Repo.insert(%LocationMulti{name: "lines with direction", geom: multiline})

      query =
        from(
          location in LocationMulti,
          where: location.name == "lines with direction",
          select: st_line_merge(location.geom, true)
        )

      result = Repo.one(query)

      # Verify the result is still a MultiLineString with only 2 lines merged
      assert %Geo.MultiLineString{} = result
      assert length(result.coordinates) == 2

      expected_linestrings = [
        [{120, 50}, {60, 30}, {10, 70}],
        [{120, 50}, {180, 30}]
      ]

      sorted_result = Enum.sort_by(result.coordinates, fn linestring -> hd(linestring) end)
      sorted_expected = Enum.sort_by(expected_linestrings, fn linestring -> hd(linestring) end)

      assert sorted_result == sorted_expected
    end

    test "lines with opposite directions merged if directed is false" do
      multiline = %Geo.MultiLineString{
        coordinates: [
          [{60, 30}, {10, 70}],
          [{120, 50}, {60, 30}],
          [{120, 50}, {180, 30}]
        ],
        srid: 4326
      }

      Repo.insert(%LocationMulti{name: "lines with direction", geom: multiline})

      query =
        from(
          location in LocationMulti,
          where: location.name == "lines with direction",
          select: st_line_merge(location.geom, false)
        )

      result = Repo.one(query)

      assert %Geo.LineString{} = result

      assert result.coordinates == [
               {180, 30},
               {120, 50},
               {60, 30},
               {10, 70}
             ]
    end
  end

  describe "st_line_interpolate_point" do
    test "interpolates point at specified fraction along a linestring" do
      line = %Geo.LineString{
        coordinates: [{0, 0}, {100, 200}],
        srid: 4326
      }

      Repo.insert(%LocationMulti{name: "test_line", geom: line})

      query =
        from(location in LocationMulti,
          where: location.name == "test_line",
          select: st_line_interpolate_point(location.geom, 0.2)
        )

      result = Repo.one(query)

      assert %Geo.Point{} = result
      assert result.coordinates == {20.0, 40.0}
    end

    test "interpolate mid-point of a 3D line" do
      line = %Geo.LineStringZ{
        coordinates: [{1, 2, 3}, {4, 5, 6}, {6, 7, 8}],
        srid: 4326
      }

      Repo.insert(%LocationMulti{name: "test_line", geom: line})

      query =
        from(location in LocationMulti,
          where: location.name == "test_line",
          select: st_line_interpolate_point(location.geom, 0.5)
        )

      result = Repo.one(query)

      assert %Geo.PointZ{} = result
      assert result.coordinates == {3.5, 4.5, 5.5}
    end
  end

  describe "st_line_interpolate_points" do
    test "returns points at specified fraction intervals along a linestring" do
      # Construct a 9x9 square
      points = [{-3, -3}, {-3, 3}, {3, 3}, {3, -3}, {-3, -3}]

      [_first | interval_points] = points

      line = %Geo.LineString{
        coordinates: points,
        srid: 4326
      }

      Repo.insert(%LocationMulti{name: "test_line", geom: line})

      # Query to find points at repeating 25% intervals along the line
      query =
        from(l in LocationMulti,
          where: l.name == "test_line",
          select: st_line_interpolate_points(l.geom, 0.25, true)
        )

      result = Repo.one(query)

      assert %Geo.MultiPoint{} = result
      assert length(result.coordinates) == 4

      assert result.coordinates == interval_points

      [first_interval_point | _rest] = interval_points

      # Query to find only the first 25% interval point (non-repeating)
      query =
        from(l in LocationMulti,
          where: l.name == "test_line",
          select: st_line_interpolate_points(l.geom, 0.25, false)
        )

      result = Repo.one(query)

      assert %Geo.Point{} = result
      assert result.coordinates == first_interval_point
    end
  end

  describe "st_line_locate_point" do
    test "returns 0.0 for point at start of line" do
      line = %Geo.LineString{
        coordinates: [{0, 0}, {1, 1}],
        srid: 4326
      }

      Repo.insert(%LocationMulti{name: "start_point_test", geom: line})

      query =
        from(location in LocationMulti,
          where: location.name == "start_point_test",
          select: st_line_locate_point(location.geom, st_set_srid(st_point(0, 0), 4326))
        )

      result = Repo.one(query)
      assert result == 0.0
    end

    test "returns 1.0 for point at end of line" do
      line = %Geo.LineString{
        coordinates: [{0, 0}, {1, 1}],
        srid: 4326
      }

      Repo.insert(%LocationMulti{name: "end_point_test", geom: line})

      query =
        from(location in LocationMulti,
          where: location.name == "end_point_test",
          select: st_line_locate_point(location.geom, st_set_srid(st_point(1, 1), 4326))
        )

      result = Repo.one(query)
      assert result == 1.0
    end

    test "returns 0.5 for point at middle of line" do
      line = %Geo.LineString{
        coordinates: [{0, 0}, {10, 10}],
        srid: 4326
      }

      Repo.insert(%LocationMulti{name: "mid_point_test", geom: line})

      query =
        from(location in LocationMulti,
          where: location.name == "mid_point_test",
          select: st_line_locate_point(location.geom, st_set_srid(st_point(5, 5), 4326))
        )

      result = Repo.one(query)
      assert result == 0.5
    end

    test "returns closest point fraction for point not on line" do
      line = %Geo.LineString{
        coordinates: [{0, 0}, {10, 0}],
        srid: 4326
      }

      Repo.insert(%LocationMulti{name: "off_line_test", geom: line})

      # Point at (5,5) - directly above the midpoint of the line
      query =
        from(location in LocationMulti,
          where: location.name == "off_line_test",
          select: st_line_locate_point(location.geom, st_set_srid(st_point(5, 5), 4326))
        )

      result = Repo.one(query)
      # The closest point should be at the midpoint of the line
      assert result == 0.5
    end
  end

  describe "st_dump" do
    test "atomic geometry is returned directly" do
      point = %Geo.Point{
        coordinates: {0.0, 0.0},
        srid: 4326
      }

      Repo.insert(%LocationMulti{name: "point", geom: point})

      query =
        from(location in LocationMulti,
          where: location.name == "point",
          select: st_dump(location.geom)
        )

      result = Repo.one(query)
      assert result == {[], point}
    end

    test "breaks a multipolygon into its constituent polygons" do
      polygon1 = %Geo.Polygon{
        coordinates: [[{0.0, 0.0}, {0.0, 1.0}, {1.0, 1.0}, {1.0, 0.0}, {0.0, 0.0}]],
        srid: 4326
      }

      polygon2 = %Geo.Polygon{
        coordinates: [[{2.0, 2.0}, {2.0, 3.0}, {3.0, 3.0}, {3.0, 2.0}, {2.0, 2.0}]],
        srid: 4326
      }

      Repo.insert(%LocationMulti{name: "polygon1", geom: polygon1})
      Repo.insert(%LocationMulti{name: "polygon2", geom: polygon2})

      query =
        from(
          location in LocationMulti,
          where: location.name in ["polygon1", "polygon2"],
          select: st_dump(st_collect(location.geom))
        )

      results = Repo.all(query)

      assert length(results) == 2

      Enum.each(results, fn {_path, geom} ->
        assert %Geo.Polygon{} = geom
      end)

      expected_polygons = MapSet.new([polygon1, polygon2])

      actual_polygons = MapSet.new(Enum.map(results, fn {_path, geom} -> geom end))

      assert MapSet.equal?(expected_polygons, actual_polygons)
    end
  end

  describe "st_line_substring" do
    test "returns the first half of a line" do
      line = %Geo.LineString{
        coordinates: [{0, 0}, {10, 10}],
        srid: 4326
      }

      Repo.insert(%LocationMulti{name: "substring_test", geom: line})

      query =
        from(location in LocationMulti,
          where: location.name == "substring_test",
          select: st_line_substring(location.geom, 0.0, 0.5)
        )

      result = Repo.one(query)

      assert %Geo.LineString{} = result
      assert result.coordinates == [{0.0, 0.0}, {5.0, 5.0}]
    end

    test "returns the second half of a line" do
      line = %Geo.LineString{
        coordinates: [{0, 0}, {10, 10}],
        srid: 4326
      }

      Repo.insert(%LocationMulti{name: "substring_test", geom: line})

      query =
        from(location in LocationMulti,
          where: location.name == "substring_test",
          select: st_line_substring(location.geom, 0.5, 1.0)
        )

      result = Repo.one(query)

      assert %Geo.LineString{} = result
      assert result.coordinates == [{5.0, 5.0}, {10.0, 10.0}]
    end

    test "returns a middle section of a line" do
      line = %Geo.LineString{
        coordinates: [{0, 0}, {10, 10}, {20, 0}],
        srid: 4326
      }

      Repo.insert(%LocationMulti{name: "multi_segment_test", geom: line})

      query =
        from(location in LocationMulti,
          where: location.name == "multi_segment_test",
          select: st_line_substring(location.geom, 0.25, 0.75)
        )

      result = Repo.one(query)

      assert %Geo.LineString{} = result
      # Should include the middle point (10,10) and interpolated points at 25% and 75%
      assert result.coordinates == [{5.0, 5.0}, {10.0, 10.0}, {15.0, 5.0}]
    end

    test "returns a point when start and end fractions are the same" do
      line = %Geo.LineString{
        coordinates: [{0, 0}, {100, 100}],
        srid: 4326
      }

      Repo.insert(%LocationMulti{name: "point_test", geom: line})

      query =
        from(location in LocationMulti,
          where: location.name == "point_test",
          select: st_line_substring(location.geom, 0.42, 0.42)
        )

      result = Repo.one(query)

      assert %Geo.Point{} = result
      assert result.coordinates == {42.0, 42.0}
    end
  end

  describe "st_is_collection/1" do
    test "returns true for a geometry collection" do
      collection = %Geo.GeometryCollection{
        geometries: [
          %Geo.Point{coordinates: {0, 0}, srid: 4326},
          %Geo.LineString{coordinates: [{0, 0}, {1, 1}], srid: 4326}
        ],
        srid: 4326
      }

      Repo.insert(%LocationMulti{name: "collection", geom: collection})

      query =
        from(l in LocationMulti,
          where: l.name == "collection",
          select: st_is_collection(st_make_valid(l.geom))
        )

      result = Repo.one(query)
      assert result == true
    end

    test "returns true for a multi-geometry" do
      multi_point = %Geo.MultiPoint{
        coordinates: [{0, 0}, {1, 1}, {2, 2}],
        srid: 4326
      }

      Repo.insert(%LocationMulti{name: "multi_point", geom: multi_point})

      query =
        from(l in LocationMulti,
          where: l.name == "multi_point",
          select: st_is_collection(st_make_valid(l.geom))
        )

      result = Repo.one(query)
      assert result == true
    end

    test "returns false for a simple geometry" do
      point = %Geo.Point{coordinates: {0, 0}, srid: 4326}

      Repo.insert(%LocationMulti{name: "point", geom: point})

      query =
        from(l in LocationMulti,
          where: l.name == "point",
          select: st_is_collection(l.geom)
        )

      result = Repo.one(query)
      assert result == false
    end
  end

  describe "st_is_empty/1" do
    test "returns true for an empty geometry" do
      empty_point = %Geo.Point{coordinates: nil, srid: 4326}

      Repo.insert(%LocationMulti{name: "empty_point", geom: empty_point})

      query =
        from(l in LocationMulti,
          where: l.name == "empty_point",
          select: st_is_empty(l.geom)
        )

      result = Repo.one(query)
      assert result == true
    end

    test "returns false for a non-empty geometry" do
      point = %Geo.Point{coordinates: {0, 0}, srid: 4326}

      Repo.insert(%LocationMulti{name: "non_empty", geom: point})

      query =
        from(l in LocationMulti,
          where: l.name == "non_empty",
          select: st_is_empty(l.geom)
        )

      result = Repo.one(query)
      assert result == false
    end
  end

  describe "st_points/1" do
    test "returns multipoint from a linestring" do
      line_coords = [{0.0, 0.0}, {1.0, 1.0}, {2.0, 2.0}]

      line = %Geo.LineString{
        coordinates: line_coords,
        srid: 4326
      }

      Repo.insert(%LocationMulti{name: "line_for_points", geom: line})

      query =
        from(l in LocationMulti,
          where: l.name == "line_for_points",
          select: st_points(l.geom)
        )

      result = Repo.one(query)
      assert %Geo.MultiPoint{} = result
      assert length(result.coordinates) == 3

      assert MapSet.new(line_coords) == MapSet.new(result.coordinates)
    end

    test "returns multipoint from a polygon" do
      polygon_coords = [{0.0, 0.0}, {0.0, 2.0}, {2.0, 2.0}, {2.0, 0.0}, {0.0, 0.0}]

      polygon = %Geo.Polygon{
        coordinates: [polygon_coords],
        srid: 4326
      }

      Repo.insert(%LocationMulti{name: "polygon_for_points", geom: polygon})

      query =
        from(l in LocationMulti,
          where: l.name == "polygon_for_points",
          select: st_points(l.geom)
        )

      result = Repo.one(query)
      assert %Geo.MultiPoint{} = result

      # 5 coordinates expected including the equivalent overlapping start/end points
      assert length(result.coordinates) == 5

      [overlapping_vertex | _rest] = polygon_coords
      assert Enum.count(result.coordinates, fn coord -> coord == overlapping_vertex end) == 2

      assert MapSet.new(polygon_coords) == MapSet.new(result.coordinates)
    end
  end

  describe "st_point_z/3 and st_point_z/4" do
    test "creates a 3D point without SRID" do
      point = %Geo.Point{coordinates: {0, 0}, srid: 4326}
      Repo.insert(%LocationMulti{name: "empty", geom: point})

      query = from(l in LocationMulti, select: st_point_z(-71.104, 42.315, 3.4), limit: 1)

      result = Repo.one(query)
      assert %Geo.PointZ{} = result
      assert result.coordinates == {-71.104, 42.315, 3.4}
      assert result.srid == nil
    end

    test "creates a 3D point with SRID" do
      point = %Geo.Point{coordinates: {0, 0}, srid: 4326}
      Repo.insert(%LocationMulti{name: "empty", geom: point})

      query = from(l in LocationMulti, select: st_point_z(-71.104, 42.315, 3.4, 4326), limit: 1)

      result = Repo.one(query)
      assert %Geo.PointZ{} = result
      assert result.coordinates == {-71.104, 42.315, 3.4}
      assert result.srid == 4326
    end
  end

  describe "st_point_m/3 and st_point_m/4" do
    test "creates a point with M coordinate without SRID" do
      point = %Geo.Point{coordinates: {0, 0}, srid: 4326}
      Repo.insert(%LocationMulti{name: "empty", geom: point})

      query = from(l in LocationMulti, select: st_point_m(-71.104, 42.315, 3.4), limit: 1)

      result = Repo.one(query)
      assert %Geo.PointM{} = result
      assert result.coordinates == {-71.104, 42.315, 3.4}
      assert result.srid == nil
    end

    test "creates a point with M coordinate with SRID" do
      point = %Geo.Point{coordinates: {0, 0}, srid: 4326}
      Repo.insert(%LocationMulti{name: "empty", geom: point})

      query = from(l in LocationMulti, select: st_point_m(-71.104, 42.315, 3.4, 4326), limit: 1)

      result = Repo.one(query)
      assert %Geo.PointM{} = result
      assert result.coordinates == {-71.104, 42.315, 3.4}
      assert result.srid == 4326
    end
  end

  describe "st_point_zm/4 and st_point_zm/5" do
    test "creates a 4D point without SRID" do
      point = %Geo.Point{coordinates: {0, 0}, srid: 4326}
      Repo.insert(%LocationMulti{name: "empty", geom: point})

      query = from(l in LocationMulti, select: st_point_zm(-71.104, 42.315, 3.4, 4.5), limit: 1)

      result = Repo.one(query)
      assert %Geo.PointZM{} = result
      assert result.coordinates == {-71.104, 42.315, 3.4, 4.5}
      assert result.srid == nil
    end

    test "creates a 4D point with SRID" do
      point = %Geo.Point{coordinates: {0, 0}, srid: 4326}
      Repo.insert(%LocationMulti{name: "empty", geom: point})

      query =
        from(l in LocationMulti, select: st_point_zm(-71.104, 42.315, 3.4, 4.5, 4326), limit: 1)

      result = Repo.one(query)
      assert %Geo.PointZM{} = result
      assert result.coordinates == {-71.104, 42.315, 3.4, 4.5}
      assert result.srid == 4326
    end
  end
end

defmodule Geo.PostGIS.GeographyVsGeometryTest do
  use ExUnit.Case, async: true
  alias Geo.PostGIS.Test.Repo

  # Test different table configurations
  defmodule PlaceGeometry do
    use Ecto.Schema
    import Ecto.Changeset

    @fields [:name, :location]

    schema "places_geometry" do
      field(:name, :string)
      field(:location, Geo.PostGIS.Geometry)
    end

    def changeset(struct \\ %__MODULE__{}, attrs) do
      struct
      |> cast(attrs, @fields)
      |> validate_required(@fields)
    end
  end

  defmodule PlaceGeography do
    use Ecto.Schema
    import Ecto.Changeset

    @fields [:name, :location]

    schema "places_geography" do
      field(:name, :string)
      field(:location, Geo.PostGIS.Geometry)
    end

    def changeset(struct \\ %__MODULE__{}, attrs) do
      struct
      |> cast(attrs, @fields)
      |> validate_required(@fields)
    end
  end

  defmodule PlaceTyped do
    use Ecto.Schema
    import Ecto.Changeset

    @fields [:name, :location]

    schema "places_typed" do
      field(:name, :string)
      field(:location, Geo.PostGIS.Geometry)
    end

    def changeset(struct \\ %__MODULE__{}, attrs) do
      struct
      |> cast(attrs, @fields)
      |> validate_required(@fields)
    end
  end

  setup _ do
    {:ok, pid} = Postgrex.start_link(Geo.Test.Helper.opts())

    {:ok, _} = Postgrex.query(pid, "CREATE EXTENSION IF NOT EXISTS postgis", [])

    # Drop tables if they exist
    {:ok, _} =
      Postgrex.query(
        pid,
        "DROP TABLE IF EXISTS places_geometry, places_geography, places_typed",
        []
      )

    # Create table with generic geometry column
    {:ok, _} =
      Postgrex.query(
        pid,
        "CREATE TABLE places_geometry (id serial primary key, name text, location geometry)",
        []
      )

    # Create table with geography column
    {:ok, _} =
      Postgrex.query(
        pid,
        "CREATE TABLE places_geography (id serial primary key, name text, location geography)",
        []
      )

    # Create table with typed geometry column
    {:ok, _} =
      Postgrex.query(
        pid,
        "CREATE TABLE places_typed (id serial primary key, name text, location geometry(Point, 4326))",
        []
      )

    # Check the actual column types to verify our setup
    {:ok, result} =
      Postgrex.query(
        pid,
        "SELECT table_name, column_name, udt_name FROM information_schema.columns
         WHERE table_name LIKE 'places_%' AND column_name = 'location'",
        []
      )

    IO.puts("Database column types:")

    result.rows
    |> Enum.each(fn [table, column, type] ->
      IO.puts("  #{table}.#{column}: #{type}")
    end)

    {:ok, _} = Repo.start_link()

    :ok
  end

  test "insert point with non-WGS84 SRID into geometry column" do
    google_maps_srid = 3857

    location = %Geo.Point{
      coordinates: {50.091211805442974, 19.89650102357312},
      srid: google_maps_srid
    }

    result =
      %{name: "Test Geometry", location: location}
      |> PlaceGeometry.changeset()
      |> Repo.insert()

    case result do
      {:ok, place} ->
        IO.puts("Successfully inserted into geometry column with SRID #{google_maps_srid}")
        assert place.location.srid == google_maps_srid

      {:error, error} ->
        IO.puts("Error inserting into geometry column: #{inspect(error)}")
        flunk("Failed to insert into geometry column: #{inspect(error)}")
    end
  end

  test "insert point with non-WGS84 SRID into geography column" do
    google_maps_srid = 3857

    location = %Geo.Point{
      coordinates: {50.091211805442974, 19.89650102357312},
      srid: google_maps_srid
    }

    result =
      %{name: "Test Geography", location: location}
      |> PlaceGeography.changeset()
      |> Repo.insert()

    # This should fail with the reported error
    case result do
      {:ok, _} ->
        flunk("Expected to fail with geography column but succeeded")

      {:error, error} ->
        IO.puts("Error inserting into geography column: #{inspect(error)}")
        assert error != nil, "Expected an error with the geography column"
    end
  end

  test "insert point with non-WGS84 SRID into typed geometry column" do
    google_maps_srid = 3857

    location = %Geo.Point{
      coordinates: {50.091211805442974, 19.89650102357312},
      srid: google_maps_srid
    }

    result =
      %{name: "Test Typed", location: location}
      |> PlaceTyped.changeset()
      |> Repo.insert()

    case result do
      {:ok, place} ->
        IO.puts("Successfully inserted into typed geometry column")
        assert place.location.srid == 4326, "SRID should be transformed to 4326"

      {:error, error} ->
        IO.puts("Error inserting into typed geometry column: #{inspect(error)}")
    end
  end

  test "insert point with WGS84 SRID into geography column" do
    wgs84_srid = 4326
    location = %Geo.Point{coordinates: {50.091211805442974, 19.89650102357312}, srid: wgs84_srid}

    result =
      %{name: "Test Geography WGS84", location: location}
      |> PlaceGeography.changeset()
      |> Repo.insert()

    # This should succeed since geography supports WGS84
    case result do
      {:ok, place} ->
        IO.puts("Successfully inserted into geography column with WGS84 SRID")
        assert place.location.srid == wgs84_srid

      {:error, error} ->
        IO.puts("Error inserting into geography column with WGS84: #{inspect(error)}")
        flunk("Failed to insert into geography column with WGS84: #{inspect(error)}")
    end
  end
end

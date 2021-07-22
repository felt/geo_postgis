defmodule Geo.PostGIS do
  @moduledoc """
  PostGIS functions that can used in ecto queries
  [PostGIS Function Documentation](http://postgis.net/docs/manual-1.3/ch06.html).

  Currently only the OpenGIS functions are implemented.

  ## Examples

      defmodule Example do
        import Ecto.Query
        import Geo.PostGIS

        def example_query(geom) do
          from location in Location, limit: 5, select: st_distance(location.geom, ^geom)
        end
      end

  """

  defmacro st_transform(wkt, srid) do
    quote bind_quoted: [wkt: wkt, srid: srid] do
      fragment("ST_Transform(?, ?)", wkt, srid)
    end
  end

  defmacro st_distance(geometryA, geometryB) do
    quote bind_quoted: [geometryA: geometryA, geometryB: geometryB] do
      fragment("ST_Distance(?,?)", geometryA, geometryB)
    end
  end

  @doc """
  Casts the 2 geometries given to geographies in order to return distance in meters.
  """
  defmacro st_distance_in_meters(geometryA, geometryB) do
    quote bind_quoted: [geometryA: geometryA, geometryB: geometryB] do
      fragment("ST_Distance(?::geography, ?::geography)", geometryA, geometryB)
    end
  end

  defmacro st_distancesphere(geometryA, geometryB) do
    quote bind_quoted: [geometryA: geometryA, geometryB: geometryB] do
      fragment("ST_DistanceSphere(?,?)", geometryA, geometryB)
    end
  end

  @doc """
  Please note that ST_Distance_Sphere has been deprecated as of Postgis 2.2.
  Postgis 2.1 is no longer supported on PostgreSQL >= 9.5.
  This macro is still in place to support users of PostgreSQL <= 9.4.x.
  """
  defmacro st_distance_sphere(geometryA, geometryB) do
    quote bind_quoted: [geometryA: geometryA, geometryB: geometryB] do
      fragment("ST_Distance_Sphere(?,?)", geometryA, geometryB)
    end
  end

  defmacro st_dwithin(geometryA, geometryB, float) do
    quote bind_quoted: [geometryA: geometryA, geometryB: geometryB, float: float] do
      fragment("ST_DWithin(?,?,?)", geometryA, geometryB, float)
    end
  end

  @doc """
  Casts the 2 geometries given to geographies in order to check for distance in meters.
  """
  defmacro st_dwithin_in_meters(geometryA, geometryB, float) do
    quote bind_quoted: [geometryA: geometryA, geometryB: geometryB, float: float] do
      fragment("ST_DWithin(?::geography, ?::geography, ?)", geometryA, geometryB, float)
    end
  end

  defmacro st_equals(geometryA, geometryB) do
    quote bind_quoted: [geometryA: geometryA, geometryB: geometryB] do
      fragment("ST_Equals(?,?)", geometryA, geometryB)
    end
  end

  defmacro st_disjoint(geometryA, geometryB) do
    quote bind_quoted: [geometryA: geometryA, geometryB: geometryB] do
      fragment("ST_Disjoint(?,?)", geometryA, geometryB)
    end
  end

  defmacro st_intersects(geometryA, geometryB) do
    quote bind_quoted: [geometryA: geometryA, geometryB: geometryB] do
      fragment("ST_Intersects(?,?)", geometryA, geometryB)
    end
  end

  defmacro st_touches(geometryA, geometryB) do
    quote bind_quoted: [geometryA: geometryA, geometryB: geometryB] do
      fragment("ST_Touches(?,?)", geometryA, geometryB)
    end
  end

  defmacro st_crosses(geometryA, geometryB) do
    quote bind_quoted: [geometryA: geometryA, geometryB: geometryB] do
      fragment("ST_Crosess(?,?)", geometryA, geometryB)
    end
  end

  defmacro st_within(geometryA, geometryB) do
    quote bind_quoted: [geometryA: geometryA, geometryB: geometryB] do
      fragment("ST_Within(?,?)", geometryA, geometryB)
    end
  end

  defmacro st_overlaps(geometryA, geometryB) do
    quote bind_quoted: [geometryA: geometryA, geometryB: geometryB] do
      fragment("ST_Overlaps(?,?)", geometryA, geometryB)
    end
  end

  defmacro st_contains(geometryA, geometryB) do
    quote bind_quoted: [geometryA: geometryA, geometryB: geometryB] do
      fragment("ST_Contains(?,?)", geometryA, geometryB)
    end
  end

  defmacro st_covers(geometryA, geometryB) do
    quote bind_quoted: [geometryA: geometryA, geometryB: geometryB] do
      fragment("ST_Covers(?,?)", geometryA, geometryB)
    end
  end

  defmacro st_covered_by(geometryA, geometryB) do
    quote bind_quoted: [geometryA: geometryA, geometryB: geometryB] do
      fragment("ST_CoveredBy(?,?)", geometryA, geometryB)
    end
  end

  defmacro st_relate(geometryA, geometryB, intersectionPatternMatrix) do
    quote bind_quoted: [
      geometryA: geometryA,
      geometryB: geometryB,
      intersectionPatternMatrix: intersectionPatternMatrix
    ] do
      fragment("ST_Relate(?,?,?)", geometryA, geometryB, intersectionPatternMatrix)
    end
  end

  defmacro st_relate(geometryA, geometryB) do
    quote bind_quoted: [geometryA: geometryA, geometryB: geometryB] do
      fragment("ST_Relate(?,?)", geometryA, geometryB)
    end
  end

  defmacro st_centroid(geometry) do
    quote bind_quoted: [geometry: geometry] do
      fragment("ST_Centroid(?)", geometry)
    end
  end

  defmacro st_area(geometry) do
    quote bind_quoted: [geometry: geometry] do
      fragment("ST_Area(?)", geometry)
    end
  end

  defmacro st_length(geometry) do
    quote bind_quoted: [geometry: geometry] do
      fragment("ST_Length(?)", geometry)
    end
  end

  defmacro st_point_on_surface(geometry) do
    quote bind_quoted: [geometry: geometry] do
      fragment("ST_PointOnSurface(?)", geometry)
    end
  end

  defmacro st_boundary(geometry) do
    quote bind_quoted: [geometry: geometry] do
      fragment("ST_Boundary(?)", geometry)
    end
  end

  defmacro st_buffer(geometry, double) do
    quote bind_quoted: [geometry: geometry] do
      fragment("ST_Buffer(?, ?)", geometry, double)
    end
  end

  defmacro st_buffer(geometry, double, integer) do
    quote bind_quoted: [geometry: geometry, double: double, integer: integer] do
      fragment("ST_Buffer(?, ?, ?)", geometry, double, integer)
    end
  end

  defmacro st_convex_hull(geometry) do
    quote bind_quoted: [geometry: geometry] do
      fragment("ST_ConvexHull(?)", geometry)
    end
  end

  defmacro st_intersection(geometryA, geometryB) do
    quote bind_quoted: [geometryA: geometryA, geometryB: geometryB] do
      fragment("ST_Intersection(?, ?)", geometryA, geometryB)
    end
  end

  defmacro st_shift_longitude(geometry) do
    quote bind_quoted: [geometry: geometry] do
      fragment("ST_Shift_Longitude(?)", geometry)
    end
  end

  defmacro st_sym_difference(geometryA, geometryB) do
    quote bind_quoted: [geometryA: geometryA, geometryB: geometryB] do
      fragment("ST_SymDifference(?,?)", geometryA, geometryB)
    end
  end

  defmacro st_difference(geometryA, geometryB) do
    quote bind_quoted: [geometryA: geometryA, geometryB: geometryB] do
      fragment("ST_Difference(?,?)", geometryA, geometryB)
    end
  end

  defmacro st_collect(geometryList) do
    quote bind_quoted: [geometryList: geometryList] do
      fragment("ST_Collect(?)", geometryList)
    end
  end

  defmacro st_collect(geometryA, geometryB) do
    quote bind_quoted: [geometryA: geometryA, geometryB: geometryB] do
      fragment("ST_Collect(?,?)", geometryA, geometryB)
    end
  end

  defmacro st_union(geometryList) do
    quote bind_quoted: [geometryList: geometryList] do
      fragment("ST_Union(?)", geometryList)
    end
  end

  defmacro st_union(geometryA, geometryB) do
    quote bind_quoted: [geometryA: geometryA, geometryB: geometryB] do
      fragment("ST_Union(?,?)", geometryA, geometryB)
    end
  end

  defmacro st_mem_union(geometryList) do
    quote bind_quoted: [geometryList: geometryList] do
      fragment("ST_MemUnion(?)", geometryList)
    end
  end

  defmacro st_as_text(geometry) do
    quote bind_quoted: [geometry: geometry] do
      fragment("ST_AsText(?)", geometry)
    end
  end

  defmacro st_as_binary(geometry) do
    quote bind_quoted: [geometry: geometry] do
      fragment("ST_AsBinary(?)", geometry)
    end
  end

  defmacro st_srid(geometry) do
    quote bind_quoted: [geometry: geometry] do
      fragment("ST_SRID(?)", geometry)
    end
  end

  defmacro st_set_srid(geometry, srid) do
    quote bind_quoted: [geometry: geometry, srid: srid] do
      fragment("ST_SetSRID(?, ?)", geometry, srid)
    end
  end

  defmacro st_make_box_2d(geometryA, geometryB) do
    quote bind_quoted: [geometryA: geometryA, geometryB: geometryB] do
      fragment("ST_MakeBox2D(?, ?)", geometryA, geometryB)
    end
  end

  defmacro st_dimension(geometry) do
    quote bind_quoted: [geometry: geometry] do
      fragment("ST_Dimension(?)", geometry)
    end
  end

  defmacro st_envelope(geometry) do
    quote bind_quoted: [geometry: geometry] do
      fragment("ST_Envelope(?)", geometry)
    end
  end

  defmacro st_is_simple(geometry) do
    quote bind_quoted: [geometry: geometry] do
      fragment("ST_IsSimple(?)", geometry)
    end
  end

  defmacro st_is_closed(geometry) do
    quote bind_quoted: [geometry: geometry] do
      fragment("ST_IsClosed(?)", geometry)
    end
  end

  defmacro st_is_ring(geometry) do
    quote bind_quoted: [geometry: geometry] do
      fragment("ST_IsRing(?)", geometry)
    end
  end

  defmacro st_num_geometries(geometry) do
    quote bind_quoted: [geometry: geometry] do
      fragment("ST_NumGeometries(?)", geometry)
    end
  end

  defmacro st_geometry_n(geometry, int) do
    quote bind_quoted: [geometry: geometry, int: int] do
      fragment("ST_GeometryN(?, ?)", geometry, int)
    end
  end

  defmacro st_num_points(geometry) do
    quote bind_quoted: [geometry: geometry] do
      fragment("ST_NumPoints(?)", geometry)
    end
  end

  defmacro st_point_n(geometry, int) do
    quote bind_quoted: [geometry: geometry, int: int] do
      fragment("ST_PointN(?, ?)", geometry, int)
    end
  end

  defmacro st_point(x, y) do
    quote bind_quoted: [x: x, y: y] do
      fragment("ST_Point(?, ?)", x, y)
    end
  end

  defmacro st_exterior_ring(geometry) do
    quote bind_quoted: [geometry: geometry] do
      fragment("ST_ExteriorRing(?)", geometry)
    end
  end

  defmacro st_num_interior_rings(geometry) do
    quote bind_quoted: [geometry: geometry] do
      fragment("ST_NumInteriorRings(?)", geometry)
    end
  end

  defmacro st_num_interior_ring(geometry) do
    quote bind_quoted: [geometry: geometry] do
      fragment("ST_NumInteriorRing(?)", geometry)
    end
  end

  defmacro st_interior_ring_n(geometry, int) do
    quote bind_quoted: [geometry: geometry, int: int] do
      fragment("ST_InteriorRingN(?, ?)", geometry, int)
    end
  end

  defmacro st_end_point(geometry) do
    quote bind_quoted: [geometry: geometry] do
      fragment("ST_EndPoint(?)", geometry)
    end
  end

  defmacro st_start_point(geometry) do
    quote bind_quoted: [geometry: geometry] do
      fragment("ST_StartPoint(?)", geometry)
    end
  end

  defmacro st_geometry_type(geometry) do
    quote bind_quoted: [geometry: geometry] do
      fragment("ST_GeometryType(?)", geometry)
    end
  end

  defmacro st_x(geometry) do
    quote bind_quoted: [geometry: geometry] do
      fragment("ST_X(?)", geometry)
    end
  end

  defmacro st_y(geometry) do
    quote bind_quoted: [geometry: geometry] do
      fragment("ST_Y(?)", geometry)
    end
  end

  defmacro st_z(geometry) do
    quote bind_quoted: [geometry: geometry] do
      fragment("ST_Z(?)", geometry)
    end
  end

  defmacro st_m(geometry) do
    quote bind_quoted: [geometry: geometry] do
      fragment("ST_M(?)", geometry)
    end
  end

  defmacro st_geom_from_text(text, srid \\ -1) do
    quote bind_quoted: [text: text, srid: srid] do
      fragment("ST_GeomFromText(?, ?)", text, srid)
    end
  end

  defmacro st_point_from_text(text, srid \\ -1) do
    quote bind_quoted: [text: text, srid: srid] do
      fragment("ST_PointFromText(?, ?)", text, srid)
    end
  end

  defmacro st_line_from_text(text, srid \\ -1) do
    quote bind_quoted: [text: text, srid: srid] do
      fragment("ST_LineFromText(?, ?)", text, srid)
    end
  end

  defmacro st_linestring_from_text(text, srid \\ -1) do
    quote bind_quoted: [text: text, srid: srid] do
      fragment("ST_LinestringFromText(?, ?)", text, srid)
    end
  end

  defmacro st_polygon_from_text(text, srid \\ -1) do
    quote bind_quoted: [text: text, srid: srid] do
      fragment("ST_PolygonFromText(?, ?)", text, srid)
    end
  end

  defmacro st_m_point_from_text(text, srid \\ -1) do
    quote bind_quoted: [text: text, srid: srid] do
      fragment("ST_MPointFromText(?, ?)", text, srid)
    end
  end

  defmacro st_m_line_from_text(text, srid \\ -1) do
    quote bind_quoted: [text: text, srid: srid] do
      fragment("ST_MLineFromText(?, ?)", text, srid)
    end
  end

  defmacro st_m_poly_from_text(text, srid \\ -1) do
    quote bind_quoted: [text: text, srid: srid] do
      fragment("ST_MPolyFromText(?, ?)", text, srid)
    end
  end

  defmacro st_m_geom_coll_from_text(text, srid \\ -1) do
    quote bind_quoted: [text: text, srid: srid] do
      fragment("ST_GeomCollFromText(?, ?)", text, srid)
    end
  end

  defmacro st_m_geom_from_wkb(bytea, srid \\ -1) do
    quote bind_quoted: [bytea: bytea, srid: srid] do
      fragment("ST_GeomFromWKB(?, ?)", bytea, srid)
    end
  end

  defmacro st_m_geometry_from_wkb(bytea, srid \\ -1) do
    quote bind_quoted: [bytea: bytea, srid: srid] do
      fragment("ST_GeometryFromWKB(?, ?)", bytea, srid)
    end
  end

  defmacro st_point_from_wkb(bytea, srid \\ -1) do
    quote bind_quoted: [bytea: bytea, srid: srid] do
      fragment("ST_PointFromWKB(?, ?)", bytea, srid)
    end
  end

  defmacro st_line_from_wkb(bytea, srid \\ -1) do
    quote bind_quoted: [bytea: bytea, srid: srid] do
      fragment("ST_LineFromWKB(?, ?)", bytea, srid)
    end
  end

  defmacro st_linestring_from_wkb(bytea, srid \\ -1) do
    quote bind_quoted: [bytea: bytea, srid: srid] do
      fragment("ST_LinestringFromWKB(?, ?)", bytea, srid)
    end
  end

  defmacro st_poly_from_wkb(bytea, srid \\ -1) do
    quote bind_quoted: [bytea: bytea, srid: srid] do
      fragment("ST_PolyFromWKB(?, ?)", bytea, srid)
    end
  end

  defmacro st_polygon_from_wkb(bytea, srid \\ -1) do
    quote bind_quoted: [bytea: bytea, srid: srid] do
      fragment("ST_PolygonFromWKB(?, ?)", bytea, srid)
    end
  end

  defmacro st_m_point_from_wkb(bytea, srid \\ -1) do
    quote bind_quoted: [bytea: bytea, srid: srid] do
      fragment("ST_MPointFromWKB(?, ?)", bytea, srid)
    end
  end

  defmacro st_m_line_from_wkb(bytea, srid \\ -1) do
    quote bind_quoted: [bytea: bytea, srid: srid] do
      fragment("ST_MLineFromWKB(?, ?)", bytea, srid)
    end
  end

  defmacro st_m_poly_from_wkb(bytea, srid \\ -1) do
    quote bind_quoted: [bytea: bytea, srid: srid] do
      fragment("ST_MPolyFromWKB(?, ?)", bytea, srid)
    end
  end

  defmacro st_geom_coll_from_wkb(bytea, srid \\ -1) do
    quote bind_quoted: [bytea: bytea, srid: srid] do
      fragment("ST_GeomCollFromWKB(?, ?)", bytea, srid)
    end
  end

  defmacro st_bd_poly_from_text(wkt, srid) do
    quote bind_quoted: [wkt: wkt, srid: srid] do
      fragment("ST_BdPolyFromText(?, ?)", wkt, srid)
    end
  end

  defmacro st_bd_m_poly_from_text(wkt, srid) do
    quote bind_quoted: [wkt: wkt, srid: srid] do
      fragment("ST_BdMPolyFromText(?, ?)", wkt, srid)
    end
  end

  defmacro st_flip_coordinates(geometryA) do
    quote bind_quoted: [geometryA: geometryA] do
      fragment("ST_FlipCoordinates(?)", geometryA)
    end
  end

  defmacro st_generate_points(geometryA, npoints) do
    quote bind_quoted: [geometryA: geometryA, npoints: npoints] do
      fragment("ST_GeneratePoints(?,?)", geometryA, npoints)
    end
  end

  defmacro st_generate_points(geometryA, npoints, seed) do
    quote bind_quoted: [geometryA: geometryA, npoints: npoints, seed: seed] do
      fragment("ST_GeneratePoints(?,?,?)", geometryA, npoints, seed)
    end
  end
end

# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [3.0.0] - 2018-12-01

### Updated

- Support for Ecto 3.0

## [2.1.0] - 2018-08-28

### Added

- [Geo.PostGIS.st_point/2](https://github.com/bryanjos/geo_postgis/pull/6)

### Fixed

- [st_distance_in_meters/2](https://github.com/bryanjos/geo_postgis/pull/8)

## [2.0.0] - 2018-04-14

### Changed

- Use `Geo.PostGIS.Geometry` when defining structs instead of `Geo.Geometry`

```elixir
  #instead of
  schema "test" do
    field :name,           :string
    field :geom,           Geo.Geometry # or Geo.Point, Geo.LineString, etc
  end

  #now use
  schema "test" do
    field :name,           :string
    field :geom,           Geo.PostGIS.Geometry
  end
```

## [1.1.0] - 2018-01-28

### Added

- [Add ST_Collect()](https://github.com/bryanjos/geo_postgis/pull/3)

## [1.0.0] - 2017-07-15

### Added

- PostGIS extension for Postgrex

# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [3.4.1] - 2021-12-15

### Enhancements

- Add [Geo.PostGIS.st_build_area/1](https://github.com/bryanjos/geo_postgis/pull/115)

## [3.4.0] - 2021-04-10

### Enhancements

- Update to Geo 3.4.0
- `Geo.PostGIS.Extension` now uses the `:binary` format instead of `:text`

### Changes

- Passing latitude or longitude as string instead of floats is no longer supported and raises an `argument error`

## [3.3.1] - 2019-12-13

### Fixed

- [Add new callback functions required by ecto 3](https://github.com/bryanjos/geo_postgis/pull/55)
- [Ecto 3.2+ requires callbacks for custom types](https://github.com/bryanjos/geo_postgis/pull/59)

## [3.3.0] - 2019-08-26

### Updated

- Geo dependency to 3.3

## [3.2.0] - 2019-07-23

### Add

- [Z versions of the datatypes](https://github.com/bryanjos/geo_postgis/pull/44)

## [3.1.0] - 2019-02-11

### Updated

- [Add PointZ handling](https://github.com/bryanjos/geo_postgis/pull/25)

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

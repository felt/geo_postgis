# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [3.4.4] - 2023-09-20

As of v3.4.4, `geo_postgis` is being maintained by the Felt team. As a company building a geospatial product on Elixir, with a track record of [supporting open source software](https://felt.com/open-source), we're excited for the future of the project.

### Elixir 1.15 compatibility

This release fixes a major compatibility issue with Elixir v1.15. When compiling a project that depends on `geo_postgis` prior to this release, you may have seen errors like this:

```
== Compilation error in file lib/my_app/my_module.ex ==
** (ArgumentError) unknown type Geo.PostGIS.Geometry for field :bounding_box
    (ecto 3.10.3) lib/ecto/schema.ex:2318: Ecto.Schema.check_field_type!/4
    (ecto 3.10.3) lib/ecto/schema.ex:1931: Ecto.Schema.__field__/4
    lib/my_app/my_module.ex:23: (module)
```

...or:

```
** (UndefinedFunctionError) function Geo.PostGIS.Geometry.type/0 is undefined (module Geo.PostGIS.Geometry is not available)
    Geo.PostGIS.Geometry.type()
```

As new contributor [@aeruder](https://github.com/aeruder) [pointed out](https://github.com/felt/geo_postgis/pull/164), this was due to a change in how Elixir 1.15 prunes code more precisely when compiling dependencies, resulting in the `Geo.PostGIS.Geometry` module being compiled out if Ecto didn't _happen_ to get compiled before it. This release fixes the issue, but you'll still need to recompile both `geo_postgis` and `ecto` to get things working again.

### Upgrade notes

If you're using Elixir 1.15, after installing v3.4.4, you'll need to run:

```sh
mix deps.clean geo_postgis ecto && mix deps.get
```

(Alternatively, a full clean build of your project will also do the job.)

Doing so will ensure `geo_postgis` compiles with the Ecto dependency and fixes the compilation errors noted above.

Note that you'll _also_ need to run the above one-liner if you need to switch back to a previous version of `geo_postgis` (e.g., when moving between branches). However, if you can stick with the new version going forward, you'll only have to run it once.

### Fixed

- Elixir 1.15 compatibility (see notes above)
- [Called out the optional Ecto dependency in `mix.exs`](https://github.com/felt/geo_postgis/pull/164)
- [Updated docs links to point to the project's new home in the Felt GitHub organization](https://github.com/felt/geo_postgis/pull/170)
- Dependency updates for `ecto_sql`, `postgrex`, and `ex_doc`
- Bumped the minimum Elixir version to v1.11, matching `postgrex` v0.16.0+

## [3.4.3] - 2023-06-20

### Fixed

-  [Corrected bitstring specifier int32 and updated deps](https://github.com/felt/geo_postgis/pull/158)

## [3.4.2] - 2022-02-23

### Fixed

-  [Fixed compilation error introduced in #121](https://github.com/felt/geo_postgis/pull/128)

## [3.4.1] - 2021-12-15

### Enhancements

- Add [Geo.PostGIS.st_build_area/1](https://github.com/felt/geo_postgis/pull/115)

## [3.4.0] - 2021-04-10

### Enhancements

- Update to Geo 3.4.0
- `Geo.PostGIS.Extension` now uses the `:binary` format instead of `:text`

### Changes

- Passing latitude or longitude as string instead of floats is no longer supported and raises an `argument error`

## [3.3.1] - 2019-12-13

### Fixed

- [Add new callback functions required by ecto 3](https://github.com/felt/geo_postgis/pull/55)
- [Ecto 3.2+ requires callbacks for custom types](https://github.com/felt/geo_postgis/pull/59)

## [3.3.0] - 2019-08-26

### Updated

- Geo dependency to 3.3

## [3.2.0] - 2019-07-23

### Add

- [Z versions of the datatypes](https://github.com/felt/geo_postgis/pull/44)

## [3.1.0] - 2019-02-11

### Updated

- [Add PointZ handling](https://github.com/felt/geo_postgis/pull/25)

## [3.0.0] - 2018-12-01

### Updated

- Support for Ecto 3.0

## [2.1.0] - 2018-08-28

### Added

- [Geo.PostGIS.st_point/2](https://github.com/felt/geo_postgis/pull/6)

### Fixed

- [st_distance_in_meters/2](https://github.com/felt/geo_postgis/pull/8)

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

- [Add ST_Collect()](https://github.com/felt/geo_postgis/pull/3)

## [1.0.0] - 2017-07-15

### Added

- PostGIS extension for Postgrex

defmodule Geo.PostGIS.Config do
  if Code.ensure_loaded?(JSON) do
    @default_json_library JSON
  else
    @default_json_library Poison
  end

  def json_library do
    Application.get_env(:geo_postgis, :json_library, @default_json_library)
  end
end

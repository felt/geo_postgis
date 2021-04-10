defmodule Geo.PostGIS.Test.Repo do
  use Ecto.Repo, otp_app: :geo_postgis, adapter: Ecto.Adapters.Postgres
end

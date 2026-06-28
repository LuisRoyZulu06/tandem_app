defmodule Tandem.Repo do
  use Ecto.Repo,
    otp_app: :tandem,
    adapter: Ecto.Adapters.Postgres
end

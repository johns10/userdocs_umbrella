defmodule UserDocs.Repo do
  use Ecto.Repo,
    otp_app: :userdocs,
    adapter: Ecto.Adapters.Postgres
end

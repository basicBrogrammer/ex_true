defmodule ExTrue.Repo do
  use Ecto.Repo,
    otp_app: :ex_true,
    adapter: Ecto.Adapters.Postgres
end

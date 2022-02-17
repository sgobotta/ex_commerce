defmodule ExCommerce.Repo do
  use Ecto.Repo,
    otp_app: :ex_commerce,
    adapter: Ecto.Adapters.Postgres
end

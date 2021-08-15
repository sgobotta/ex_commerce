defmodule ExCommerce.Seeds.Users do
  @moduledoc """
  Seeds for the User model
  """

  alias ExCommerce.Repo
  alias ExCommerce.Accounts.User
  alias ExCommerce.Seeds.Utils

  require Logger

  @json_file "#{__DIR__}/users.json"

  @spec populate :: :ok
  def populate do
    with {:ok, body} <- File.read(@json_file),
      {:ok, users} <- Jason.decode(body, keys: :atoms) do

      date_keys = [:confirmed_at, :inserted_at, :updated_at]
      users = for user <- users do
        Map.merge(user, Utils.dates_to_naive_datetime(user, date_keys))
      end

      {count, _} = Repo.insert_all(User, users)
      count

      :ok = Logger.info("✅ Inserted #{count} users.")

      :ok
    end
  end
end

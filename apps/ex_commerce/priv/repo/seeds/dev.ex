defmodule ExCommerce.Seeds.Dev do
  @moduledoc """
  Runs development fixtures.
  """

  require Logger

  alias ExCommerce.Seeds.Shops
  alias ExCommerce.Seeds.Users

  @spec populate :: :ok
  def populate do
    # Run seeds here
    :ok = Users.populate()
    :ok = Shops.populate()

    :ok = Logger.info("🌱 Succesfully created development seeds.")

    :ok
  end
end

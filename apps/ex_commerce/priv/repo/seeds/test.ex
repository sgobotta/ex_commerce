defmodule ExCommerce.Seeds.Test do
  @moduledoc """
  Runs test fixtures.
  """

  require Logger

  @spec populate :: :ok
  def populate do
    # Run seeds here
    :ok = Logger.info("🌱 Succesfully created test seeds.")

    :ok
  end
end

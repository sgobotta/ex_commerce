defmodule ExCommerce.Seeds do
  @moduledoc """
  Interface for running fixture seeds per environment.
  """

  alias ExCommerce.Seeds

  @spec populate(atom()) :: :ok
  def populate(:dev) do
    :ok = Seeds.Dev.populate()
  end

  def populate(:test) do
    :ok = Seeds.Test.populate()
  end

  def populate(_), do: :ok
end

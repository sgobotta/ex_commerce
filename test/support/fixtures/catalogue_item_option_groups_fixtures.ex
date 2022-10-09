defmodule ExCommerce.CatalogueItemOptionGroupsFixtures do
  @moduledoc """
  This module defines test helpers for creating entities via the
  `ExCommerce.Offerings.CatalogueItemOptionGroup` context.
  """

  alias ExCommerce.Offerings
  alias ExCommerce.Offerings.CatalogueItemOptionGroup

  import ExCommerce.FixtureHelpers

  @valid_attrs %{
    mandatory: true,
    max_selection: 42,
    multiple_selection: true,
    code: "some code",
    name: "some name",
    description: "some description"
  }
  @update_attrs %{
    mandatory: false,
    max_selection: 43,
    multiple_selection: false,
    code: "some updated code",
    name: "some updated name",
    description: "some updated description"
  }
  @invalid_attrs %{
    mandatory: nil,
    max_selection: nil,
    multiple_selection: nil,
    code: nil,
    name: nil,
    description: nil
  }

  def valid_attrs(attrs \\ %{}), do: attrs |> Enum.into(@valid_attrs)
  def update_attrs(attrs \\ %{}), do: attrs |> Enum.into(@update_attrs)
  def invalid_attrs(attrs \\ %{}), do: attrs |> Enum.into(@invalid_attrs)

  def create(attrs \\ %{}) do
    {:ok, %CatalogueItemOptionGroup{} = catalogue_item_option_group} =
      attrs
      |> maybe_assign_brand()
      |> Enum.into(@valid_attrs)
      |> Offerings.create_catalogue_item_option_group()

    catalogue_item_option_group
  end
end

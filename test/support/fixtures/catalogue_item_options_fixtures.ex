defmodule ExCommerce.CatalogueItemOptionsFixtures do
  @moduledoc """
  This module defines test helpers for creating entities via the
  `ExCommerce.Offerings.CatalogueItemOption` context.
  """

  alias ExCommerce.Offerings

  alias ExCommerce.Offerings.CatalogueItemOption

  import ExCommerce.FixtureHelpers

  @valid_attrs %{price_modifier: 44, is_visible: true}
  @update_attrs %{price_modifier: 45, is_visible: false}
  @invalid_attrs %{price_modifier: nil, is_visible: nil}

  def valid_attrs(attrs \\ %{}), do: attrs |> Enum.into(@valid_attrs)
  def update_attrs(attrs \\ %{}), do: attrs |> Enum.into(@update_attrs)
  def invalid_attrs(attrs \\ %{}), do: attrs |> Enum.into(@invalid_attrs)

  def create(attrs \\ %{}) do
    {:ok, %CatalogueItemOption{} = catalogue_item_option} =
      attrs
      |> maybe_assign_brand()
      |> maybe_assign_catalogue_item()
      |> maybe_assign_catalogue_item_variant()
      |> maybe_assign_catalogue_item_option_group()
      |> Enum.into(@valid_attrs)
      |> Offerings.create_catalogue_item_option()

    catalogue_item_option
  end
end

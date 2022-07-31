defmodule ExCommerce.CatalogueCategoriesFixtures do
  @moduledoc """
  This module defines test helpers for creating entities via the
  `ExCommerce.Offerings.CatalogueCategory` context.
  """

  alias ExCommerce.Offerings
  alias ExCommerce.Offerings.CatalogueCategory

  import ExCommerce.FixtureHelpers

  @valid_attrs %{
    code: "some code",
    description: "some description",
    name: "some name"
  }
  @update_attrs %{
    code: "some updated code",
    description: "some updated description",
    name: "some updated name"
  }
  @invalid_attrs %{code: nil, description: nil, name: nil}

  def valid_attrs(attrs \\ %{}), do: attrs |> Enum.into(@valid_attrs)
  def update_attrs(attrs \\ %{}), do: attrs |> Enum.into(@update_attrs)
  def invalid_attrs(attrs \\ %{}), do: attrs |> Enum.into(@invalid_attrs)

  def create(attrs \\ %{}) do
    {:ok, %CatalogueCategory{} = catalogue_category} =
      attrs
      |> maybe_assign_brand()
      |> Enum.into(@valid_attrs)
      |> Offerings.create_catalogue_category()

    catalogue_category
  end
end

defmodule ExCommerce.BrandsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `ExCommerce.Marketplaces.Brand` context.
  """

  alias ExCommerce.Marketplaces
  alias ExCommerce.Marketplaces.Brand

  @valid_attrs %{
    name: "some name",
    slug: "some-slug"
  }
  @update_attrs %{
    name: "some updated name",
    slug: "some-updated-slug"
  }
  @invalid_attrs %{
    name: nil,
    slug: nil
  }

  def valid_attrs(attrs \\ %{}) do
    unique_name = unique_brand_name()

    unique_slug =
      unique_name
      |> String.downcase()
      |> String.replace(" ", "-")

    Enum.into(
      attrs,
      Map.merge(
        @valid_attrs,
        %{
          name: unique_name,
          slug: unique_name
        }
      )
    )
  end

  def update_attrs(attrs \\ %{}), do: attrs |> Enum.into(@update_attrs)
  def invalid_attrs(attrs \\ %{}), do: attrs |> Enum.into(@invalid_attrs)

  def create(attrs \\ %{}) do
    {:ok, %Brand{} = brand} =
      attrs
      |> Enum.into(valid_attrs())
      |> ExCommerce.Marketplaces.create_brand()

    brand
  end

  defp unique_brand_name, do: "brand#{System.unique_integer()}"
end

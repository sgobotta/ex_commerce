defmodule ExCommerce.CataloguesFixtures do
  @moduledoc """
  This module defines test helpers for creating entities via the
  `ExCommerce.Offerings.Catalogue` context.
  """

  alias ExCommerce.BrandsFixtures
  alias ExCommerce.Marketplaces.Brand
  alias ExCommerce.Offerings
  alias ExCommerce.Offerings.Catalogue

  @valid_attrs %{
    name: "some name"
  }
  @update_attrs %{
    name: "some updated name"
  }
  @invalid_attrs %{
    name: nil
  }

  def create(attrs \\ %{}) do
    attrs = assign_brand_maybe(attrs)

    {:ok, %Catalogue{} = catalogue} =
      attrs
      |> Enum.into(@valid_attrs)
      |> Offerings.create_catalogue()

    catalogue
  end

  defp assign_brand_maybe(attrs) do
    case Map.has_key?(attrs, :brand_id) do
      false ->
        %Brand{id: brand_id} = BrandsFixtures.create()
        Map.merge(attrs, %{brand_id: brand_id})

      true ->
        attrs
    end
  end
end
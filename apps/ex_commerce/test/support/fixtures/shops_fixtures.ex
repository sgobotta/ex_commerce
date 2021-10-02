defmodule ExCommerce.ShopsFixtures do
  @moduledoc """
  This module defines test helpers for creating entities via the
  `ExCommerce.Marketplaces.Brand` context.
  """

  alias ExCommerce.BrandsFixtures
  alias ExCommerce.Marketplaces

  @valid_attrs %{
    name: "some name",
    slug: "some-slug",
    description: "some description",
    telephone: "some telephone",
    banner_message: "some banner_message",
    address: "some address"
  }
  @update_attrs %{
    name: "some updated name",
    slug: "some-updated-slug",
    description: "some updated description",
    telephone: "some updated telephone",
    banner_message: "some updated banner_message",
    address: "some updated address"
  }
  @invalid_attrs %{
    name: nil,
    slug: nil,
    description: nil,
    telephone: nil,
    banner_message: nil,
    address: nil
  }

  def create(attrs \\ %{}) do
    attrs = assign_brand_maybe(attrs)

    {:ok, shop} =
      attrs
      |> Enum.into(@valid_attrs)
      |> Marketplaces.create_shop()

    shop
  end

  defp assign_brand_maybe(attrs) do
    case Map.has_key?(attrs, :brand_id) do
      false ->
        %{id: brand_id} = BrandsFixtures.create()
        Map.merge(attrs, %{brand_id: brand_id})

      true ->
        attrs
    end
  end
end

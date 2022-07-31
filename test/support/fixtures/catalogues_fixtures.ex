defmodule ExCommerce.CataloguesFixtures do
  @moduledoc """
  This module defines test helpers for creating entities via the
  `ExCommerce.Offerings.Catalogue` context.
  """

  alias ExCommerce.Offerings
  alias ExCommerce.Offerings.Catalogue

  import ExCommerce.FixtureHelpers

  @valid_attrs %{
    code: "some code",
    name: "some name"
  }
  @update_attrs %{
    code: "some updated code",
    name: "some updated name"
  }
  @invalid_attrs %{
    code: nil,
    name: nil
  }

  def valid_attrs(attrs \\ %{}), do: attrs |> Enum.into(@valid_attrs)
  def update_attrs(attrs \\ %{}), do: attrs |> Enum.into(@update_attrs)
  def invalid_attrs(attrs \\ %{}), do: attrs |> Enum.into(@invalid_attrs)

  def create(attrs \\ %{}) do
    {:ok, %Catalogue{} = catalogue} =
      attrs
      |> maybe_assign_brand()
      |> Enum.into(@valid_attrs)
      |> Offerings.create_catalogue()

    catalogue
  end
end

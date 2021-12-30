defmodule ExCommerce.EctoHelpers do
  @moduledoc """
  Dedicated module for Ecto and Ecto.Changeset helper functions.
  """

  @spec put_assoc(Ecto.Changeset.t(), map, atom, any) ::
          Ecto.Changeset.t()
  @doc """
  Given a changeset, some attrs, a schema property and a function that lists
  entities by id, searches for a target property in attrs to apply a changeset
  change of a list of entities.

  ## Examples:

      iex> EctoHelpers.put_assoc(
      ...>  ExCommerce.Offerings.CatalogueCategory.changeset(
      ...>    %ExCommerce.Offerings.CatalogueCategory{},
      ...>    %{}
      ...>  ),
      ...>  %{"items" => ["61d7fed5-150f-4111-bb58-4621bf7fa54e"]},
      ...>  :items,
      ...>  &Offerings.filter_catalogue_items_by_id/1
      ...> )
      %Ecto.Changeset{}

  """
  def put_assoc(changeset, attrs, property, list_function) do
    entities =
      case Map.get(attrs, Atom.to_string(property)) do
        nil ->
          []

        entity_ids ->
          list_function.(entity_ids)
      end

    Ecto.Changeset.put_assoc(changeset, property, entities)
  end
end

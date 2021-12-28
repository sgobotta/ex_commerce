defmodule ExCommerceWeb.Helpers.CheckboxHelper do
  @moduledoc """
  Defines a checkbox element for forms.
  """
  use Phoenix.HTML

  @doc """
  Renders multiple checkboxes.

  ## Example

      iex> multiselect_checkboxes(
      ...>   f,
      ...>   :categories,
      ...>   Enum.map(@categories, fn c -> { c.code, c.id } end),
      ...>   selected: Enum.map(@changeset.data.categories, &(&1.id))
      ...> )
      <div class="checkbox">
        <label>
          <input name="property[categories][]" id="property_categories_1" type="checkbox" value="1" checked>
          <input name="property[categories][]" id="property_categories_2" type="checkbox" value="2">
        </label>
      </div>

  """
  def multiselect_checkboxes(form, field, options, opts \\ []) do
    {selected, _} = get_selected_values(form, field, opts)
    selected_as_strings = Enum.map(selected, &"#{&1}")

    for {value, key} <- options, into: [] do
      content_tag(:label, class: "checkbox-inline") do
        [
          tag(:input,
            name: input_name(form, field) <> "[]",
            id: input_id(form, field, key),
            type: "checkbox",
            value: key,
            checked: Enum.member?(selected_as_strings, "#{key}")
          ),
          value
        ]
      end
    end
  end

  defp get_selected_values(form, field, opts) do
    {selected, opts} = Keyword.pop(opts, :selected)
    param = field_to_string(field)

    case form do
      %{params: %{^param => sent}} ->
        {sent, opts}

      _params ->
        {selected || input_value(form, field), opts}
    end
  end

  defp field_to_string(field) when is_atom(field), do: Atom.to_string(field)
  defp field_to_string(field) when is_binary(field), do: field
end

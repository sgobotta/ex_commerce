defmodule ExCommerceWeb.DataDisplayView do
  use ExCommerceWeb, :view

  def render("tooltip", assigns) do
    opts =
      assigns
      |> Map.put_new(:extra_classes, "")
      |> Map.put_new(:text, gettext("Placeholder text"))

    render("tooltip.html", opts)
  end
end

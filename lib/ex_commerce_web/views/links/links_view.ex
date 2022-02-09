defmodule ExCommerceWeb.LinksView do
  @moduledoc false

  use ExCommerceWeb, :view

  def render("link", assigns) do
    opts =
      assigns
      |> Map.put_new(:icon, nil)
      |> Map.put_new(:name, "unknown-name")
      |> Map.put_new(:text, gettext("Link name"))
      |> Map.put_new(:to, "#")
      |> Map.put_new(:class, "")

    render("link.html", opts)
  end
end

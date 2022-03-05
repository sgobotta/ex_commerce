defmodule ExCommerceWeb.ButtonsView do
  @moduledoc false

  use ExCommerceWeb, :view

  def render("logout_button", assigns) do
    opts = Map.put_new(assigns, :classes, "")
    render("logout_button.html", opts)
  end

  def render("register_button", _assigns) do
    render("register_button.html", [])
  end

  def render("admin_dashboard_button", _assigns) do
    render("admin_dashboard_button.html", [])
  end

  def render("file_input", assigns) do
    opts =
      assigns
      |> Map.put_new(:text, gettext("Choose Files"))
      |> Map.put_new(:label_classes, "")
      |> Map.put_new(:input_classes, "")
      |> Map.put_new(:uploads, [])

    render("file_input.html", opts)
  end
end

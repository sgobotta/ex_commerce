defmodule ExCommerceWeb.ButtonsView do
  @moduledoc false

  use ExCommerceWeb, :view

  def render("login_button", _assigns) do
    render("login_button.html", [])
  end

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

  def render("icon_button", _assigns) do
    render("icon_button.html", [])
  end
end

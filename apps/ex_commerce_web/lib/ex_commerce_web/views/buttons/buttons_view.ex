defmodule ExCommerceWeb.Buttons do
  @moduledoc false

  use ExCommerceWeb, :view

  def render("login_button", _assigns) do
    render("login_button.html", [])
  end

  def render("register_button", _assigns) do
    render("register_button.html", [])
  end

  def render("icon_button", _assigns) do
    render("icon_button.html", [])
  end
end

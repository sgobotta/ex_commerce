defmodule ExCommerceWeb.WebView do
  use ExCommerceWeb, :view

  def render("footer", assigns) do
    render("footer.html", assigns)
  end
end

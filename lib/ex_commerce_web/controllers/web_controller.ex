defmodule ExCommerceWeb.WebController do
  use ExCommerceWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end

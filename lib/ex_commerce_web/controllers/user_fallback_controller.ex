defmodule ExCommerceWeb.UserFallbackController do
  use ExCommerceWeb, :controller

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(ExCommerceWeb.ErrorView)
    |> render(:"404")
  end

  def call(conn, {:error, :unauthorized}) do
    conn
    |> put_status(403)
    |> put_view(ExCommerceWeb.ErrorView)
    |> render(:"403")
  end

  def call(conn, {:recaptcha_error, message}) do
    render(conn, "new.html", error_message: message)
  end
end

defmodule ExCommerceWeb.UserSessionController do
  use ExCommerceWeb, :controller

  alias ExCommerce.Accounts
  alias ExCommerceWeb.UserAuth

  require Logger

  def new(conn, _params) do
    render(conn, "new.html", error_message: nil)
  end

  def create(conn, %{"user" => user_params} = params) do
    with {:ok, response} <- Recaptcha.verify(params["g-recaptcha-response"]),
         :ok <- UserAuth.validate_recaptcha(response) do
      %{"email" => email, "password" => password} = user_params

      if user = Accounts.get_user_by_email_and_password(email, password) do
        UserAuth.log_in_user(conn, user, user_params)
      else
        render(conn, "new.html",
          error_message: gettext("Invalid email or password")
        )
      end
    else
      {:recaptcha_error, message} ->
        render(conn, "new.html", error_message: message)

      {:error, [:timeout_or_duplicate]} ->
        render(conn, "new.html", error_message: gettext("Invalid Captcha"))

      error ->
        Logger.error("Unhandled error: #{inspect(error)}")

        render(conn, "new.html",
          error_message:
            gettext(
              "Something's wrong, please try again later or contact support,"
            )
        )
    end
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, gettext("Logged out successfully."))
    |> UserAuth.log_out_user()
  end
end

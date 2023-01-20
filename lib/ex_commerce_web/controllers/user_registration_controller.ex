defmodule ExCommerceWeb.UserRegistrationController do
  use ExCommerceWeb, :controller

  alias ExCommerce.Accounts
  alias ExCommerce.Accounts.User
  alias ExCommerceWeb.UserAuth

  action_fallback ExCommerceWeb.UserRegistrationFallbackController

  def new(conn, _params) do
    changeset = Accounts.change_user_registration(%User{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params} = params) do
    with :ok <- UserAuth.validate_recaptcha(params),
         user_params <- Map.put(user_params, "valid_captcha", true) do
      case Accounts.register_user(user_params) do
        {:ok, user} ->
          {:ok, _} =
            Accounts.deliver_user_confirmation_instructions(
              user,
              &Routes.user_confirmation_url(conn, :confirm, &1)
            )

          conn
          |> put_flash(
            :info,
            gettext("Please check %{email} inbox.", email: user.email)
          )
          |> put_session(
            :user_return_to,
            Routes.user_settings_path(conn, :email_sent)
          )
          |> UserAuth.log_in_user(user)

        {:error, %Ecto.Changeset{} = changeset} ->
          render(conn, "new.html", changeset: changeset)
      end
    end
  end
end

defmodule ExCommerceWeb.UserRegistrationFallbackController do
  @moduledoc """
  Fallback convenience for user registration requests.
  """
  use ExCommerceWeb, :controller

  alias ExCommerce.Accounts
  alias ExCommerce.Accounts.User

  def call(conn, {:recaptcha_error, message}) when is_binary(message) do
    {:error, %Ecto.Changeset{} = changeset} =
      Accounts.change_user_registration(
        %User{},
        conn.body_params["user"] || %{}
      )
      |> Ecto.Changeset.add_error(:valid_captcha, message)
      |> Ecto.Changeset.apply_action(:insert)

    render(conn, "new.html", changeset: changeset)
  end
end

defmodule ExCommerceWeb.UserRegistrationController do
  use ExCommerceWeb, :controller

  alias ExCommerce.Accounts
  alias ExCommerce.Accounts.User
  alias ExCommerceWeb.UserAuth

  def new(conn, _params) do
    changeset = Accounts.change_user_registration(%User{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        {:ok, _} =
          Accounts.deliver_user_confirmation_instructions(
            user,
            &Routes.user_confirmation_url(conn, :confirm, &1)
          )

        conn
        |> put_flash(:info, "Please check #{user.email} inbox.")
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

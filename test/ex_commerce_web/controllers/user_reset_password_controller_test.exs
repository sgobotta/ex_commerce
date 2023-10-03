defmodule ExCommerceWeb.UserResetPasswordControllerTest do
  @moduledoc false

  use ExCommerceWeb.ConnCase, async: true

  import ExCommerce.AccountsFixtures

  alias ExCommerce.Accounts
  alias ExCommerce.Repo

  setup do
    %{user: user_fixture()}
  end

  describe "GET /users/reset_password" do
    test "renders the reset password page", %{conn: conn} do
      conn = get(conn, Routes.user_reset_password_path(conn, :new))
      response = html_response(conn, 200)
      assert response =~ gettext("Forgot your password?")
    end
  end

  describe "POST /users/reset_password" do
    alias ExCommerceWeb.UserAuth

    @recaptcha_response_field UserAuth.get_recaptcha_response_field()

    @tag :capture_log
    test "sends a new reset password token", %{conn: conn, user: user} do
      conn =
        post(conn, Routes.user_reset_password_path(conn, :create), %{
          "user" => %{"email" => user.email},
          @recaptcha_response_field => "valid_response"
        })

      assert redirected_to(conn) == "/"

      assert get_flash(conn, :info) =~
               gettext(
                 "If your email is in our system, you will receive instructions to reset your password shortly."
               )

      assert Repo.get_by!(Accounts.UserToken, user_id: user.id).context ==
               "reset_password"
    end

    test "does not send reset password token if email is invalid", %{conn: conn} do
      conn =
        post(conn, Routes.user_reset_password_path(conn, :create), %{
          "user" => %{"email" => "unknown@example.com"},
          @recaptcha_response_field => "valid_response"
        })

      assert redirected_to(conn) == "/"

      assert get_flash(conn, :info) =~
               gettext(
                 "If your email is in our system, you will receive instructions to reset your password shortly."
               )

      assert Repo.all(Accounts.UserToken) == []
    end
  end

  describe "GET /users/reset_password/:token" do
    setup %{user: user} do
      token =
        extract_user_token(fn url ->
          Accounts.deliver_user_reset_password_instructions(user, url)
        end)

      %{token: token}
    end

    test "renders reset password", %{conn: conn, token: token} do
      conn = get(conn, Routes.user_reset_password_path(conn, :edit, token))
      assert html_response(conn, 200) =~ gettext("Reset password")
    end

    test "does not render reset password with invalid token", %{conn: conn} do
      conn = get(conn, Routes.user_reset_password_path(conn, :edit, "oops"))
      assert redirected_to(conn) == "/"

      assert get_flash(conn, :error) =~
               gettext("Reset password link is invalid or it has expired.")
    end
  end

  describe "PUT /users/reset_password/:token" do
    setup %{user: user} do
      token =
        extract_user_token(fn url ->
          Accounts.deliver_user_reset_password_instructions(user, url)
        end)

      %{token: token}
    end

    test "resets password once", %{conn: conn, user: user, token: token} do
      conn =
        put(conn, Routes.user_reset_password_path(conn, :update, token), %{
          "user" => %{
            "password" => "new valid password",
            "password_confirmation" => "new valid password"
          }
        })

      assert redirected_to(conn) == Routes.user_session_path(conn, :new)
      refute get_session(conn, :user_token)
      assert get_flash(conn, :info) =~ gettext("Password reset successfully.")

      assert Accounts.get_user_by_email_and_password(
               user.email,
               "new valid password"
             )
    end

    test "does not reset password on invalid data", %{conn: conn, token: token} do
      conn =
        put(conn, Routes.user_reset_password_path(conn, :update, token), %{
          "user" => %{
            "password" => "too short",
            "password_confirmation" => "does not match"
          }
        })

      response = html_response(conn, 200)
      assert response =~ gettext("Reset password")

      assert response =~
               dngettext(
                 "errors",
                 "should be at least %{count} character(s)",
                 "should be at least %{count} character(s)",
                 12,
                 %{count: 12}
               )

      assert response =~ dgettext("errors", "does not match password")
    end

    test "does not reset password with invalid token", %{conn: conn} do
      conn = put(conn, Routes.user_reset_password_path(conn, :update, "oops"))
      assert redirected_to(conn) == "/"

      assert get_flash(conn, :error) =~
               gettext("Reset password link is invalid or it has expired.")
    end
  end
end

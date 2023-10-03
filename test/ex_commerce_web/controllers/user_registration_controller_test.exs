defmodule ExCommerceWeb.UserRegistrationControllerTest do
  @moduledoc false

  use ExCommerceWeb.ConnCase, async: true

  import ExCommerce.AccountsFixtures

  describe "GET /users/register" do
    test "renders registration page", %{conn: conn} do
      conn = get(conn, Routes.user_registration_path(conn, :new))
      response = html_response(conn, 200)
      assert response =~ gettext("Start for free today")
      assert response =~ gettext("Log in") <> "</a>"
      assert response =~ gettext("Register") <> "</button>"
    end

    test "redirects if already logged in", %{conn: conn} do
      conn =
        conn
        |> log_in_user(user_fixture())
        |> get(Routes.user_registration_path(conn, :new))

      assert redirected_to(conn) == "/"
    end
  end

  describe "POST /users/register" do
    alias ExCommerceWeb.UserAuth

    @recaptcha_response_field UserAuth.get_recaptcha_response_field()

    @tag :capture_log
    test "creates account and logs the user in", %{conn: conn} do
      email = unique_user_email()

      conn =
        post(conn, Routes.user_registration_path(conn, :create), %{
          "user" => valid_user_attributes(email: email),
          @recaptcha_response_field => "valid_response"
        })

      assert get_session(conn, :user_token)
      assert redirected_to(conn) =~ "/"

      # Now do a logged in request and assert on the menu
      conn = get(conn, "/")
      _response = html_response(conn, 200)
      # assert response =~ email
      # assert response =~ "Settings</a>"
      # assert response =~ "Log out</a>"
    end

    test "render errors for invalid data", %{conn: conn} do
      conn =
        post(conn, Routes.user_registration_path(conn, :create), %{
          "user" => %{"email" => "with spaces", "password" => "too short"}
        })

      response = html_response(conn, 200)
      assert response =~ gettext("Start for free today")

      assert response =~
               dgettext("errors", "must have the @ sign and no spaces")

      assert response =~
               dngettext(
                 "errors",
                 "should be at least %{count} character(s)",
                 "should be at least %{count} character(s)",
                 12,
                 %{count: 12}
               )
    end
  end
end

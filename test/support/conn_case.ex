defmodule ExCommerceWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common data structures and query the data layer.

  Finally, if the test case interacts with the database,
  we enable the SQL sandbox, so changes done to the database
  are reverted at the end of every test. If you are using
  PostgreSQL, you can even run database tests asynchronously
  by setting `use ExCommerceWeb.ConnCase, async: true`, although
  this option is not recommended for other databases.
  """

  use ExUnit.CaseTemplate

  alias Ecto.Adapters.SQL.Sandbox

  import Phoenix.LiveViewTest

  using do
    quote do
      # Import conveniences for testing with connections
      import Plug.Conn
      import Phoenix.ConnTest
      import ExCommerceWeb.ConnCase

      alias ExCommerceWeb.Router.Helpers, as: Routes

      # The default endpoint for testing
      @endpoint ExCommerceWeb.Endpoint

      def assert_redirects_with_error(conn, from: from, to: to) do
        assert {:error, {:redirect, %{to: ^to}}} = live(conn, from)
      end
    end
  end

  setup tags do
    :ok = Sandbox.checkout(ExCommerce.Repo)

    unless tags[:async] do
      Sandbox.mode(ExCommerce.Repo, {:shared, self()})
    end

    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end

  @doc """
  Setup helper that registers and logs in users.

      setup :register_and_log_in_user

  It stores an updated connection and a registered user in the
  test context.
  """
  def register_and_log_in_user(%{conn: conn}) do
    user = ExCommerce.AccountsFixtures.user_fixture()
    %{conn: log_in_user(conn, user), user: user}
  end

  @doc """
  Setup helper that registers and logs in confirmed users.

      setup :register_and_log_in_user

  It stores an updated connection and a registered user in the
  test context.
  """
  def register_and_log_in_confirmed_user(%{conn: conn}) do
    {:ok, confirmed_at} = Ecto.Type.cast(:naive_datetime, DateTime.utc_now())

    user =
      ExCommerce.AccountsFixtures.user_fixture(%{
        confirmed_at: confirmed_at
      })

    %{conn: log_in_user(conn, user), user: user}
  end

  @doc """
  Logs the given `user` into the `conn`.

  It returns an updated `conn`.
  """
  def log_in_user(conn, user) do
    token = ExCommerce.Accounts.generate_user_session_token(user)

    conn
    |> Phoenix.ConnTest.init_test_session(%{})
    |> Plug.Conn.put_session(:user_token, token)
  end
end

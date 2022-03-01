defmodule ExCommerceWeb.AdminNav do
  @moduledoc false

  import Phoenix.LiveView

  def on_mount(:default, _params, _session, socket) do
    {
      :cont,
      socket
      |> attach_hook(:active_tab, :handle_params, &handle_active_tab_params/3)
    }
  end

  defp handle_active_tab_params(params, _url, socket) do
    active_tab =
      case {socket.view, socket.assigns.live_action} do
        {_view, _action} ->
          nil

      end

    {:cont, assign(socket, active_tab: active_tab)}
  end

  defp current_user_profile_username(socket) do
    if user = socket.assigns.current_user do
      user.username
    end
  end
end

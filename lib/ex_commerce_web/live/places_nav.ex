defmodule ExCommerceWeb.PlacesNav do
  @moduledoc false

  import Phoenix.LiveView

  def on_mount(:check_action, _params, _session, socket) do
    {:cont,
     socket
     |> attach_hook(:expanded, :handle_params, &handle_expanded_params/3)}
  end

  defp handle_expanded_params(_params, _url, socket) do
    expanded = socket.assigns.live_action in [:show_catalogue]

    {:cont, assign(socket, :expanded, expanded)}
  end
end

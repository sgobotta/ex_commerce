defmodule ExCommerceWeb.CheckoutNav do
  @moduledoc false

  import Phoenix.LiveView

  def on_mount(:check_action, _params, _session, socket) do
    {:cont,
     socket
     |> attach_hook(:expanded, :handle_params, &handle_expanded_params/3)}
  end

  defp handle_expanded_params(_params, _url, socket) do
    {:cont, socket}
  end
end

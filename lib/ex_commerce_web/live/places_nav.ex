defmodule ExCommerceWeb.PlacesNav do
  @moduledoc false

  import Phoenix.LiveView

  def on_mount(:check_action, _params, _session, socket) do
    {:cont,
     socket
     |> attach_hook(:expanded, :handle_params, &handle_expanded_params/3)}
  end

  defp handle_expanded_params(_params, _url, socket) do
    %{assigns: %{live_action: live_action}} = socket

    {:cont,
     socket
     |> assign(:container_classes, get_classes(:container, live_action))
     |> assign(:header_classes, get_classes(:header, live_action))
     |> assign(:banner_classes, get_classes(:banner, live_action))
     |> assign(
       :avatar_container_classes,
       get_classes(:avatar_container, live_action)
     )
     |> assign(:avatar_size_classes, get_classes(:avatar_size, live_action))
     |> assign(:avatar_classes, get_classes(:avatar, live_action))
     |> assign(
       :content_container_classes,
       get_classes(:content_container, live_action)
     )
     |> assign(:content_classes, get_classes(:content, live_action))
     |> assign(
       :accordion_container_classes,
       get_classes(:accordion_container, live_action)
     )
     |> assign(:accordion_classes, get_classes(:accordion, live_action))}
  end

  def get_classes(:container, :show), do: ""
  def get_classes(:container, :show_catalogue), do: ""
  def get_classes(:container, :show_item), do: ""
  def get_classes(:container, _action), do: ""

  def get_classes(:header, :show), do: "basis-2/4 h-full -translate-y-0"

  def get_classes(:header, :show_catalogue),
    do: "basis-none h-0 -translate-y-96"

  def get_classes(:header, :show_item), do: "basis-2/4 h-full -translate-y-0"
  def get_classes(:header, _action), do: ""

  def get_classes(:banner, :show), do: "translate-y-0"
  def get_classes(:banner, :show_catalogue), do: "-translate-y-96"
  def get_classes(:banner, :show_item), do: "-translate-y-96"
  def get_classes(:banner, _action), do: ""

  def get_classes(:avatar_container, :show),
    do: "absolute top-44 sm:top-60 translate-y-0 w-full flex basis-2/4"

  def get_classes(:avatar_container, :show_catalogue),
    do: "absolute top-0 sm:top-60 -translate-y-96"

  def get_classes(:avatar_container, :show_item),
    do: "absolute top-8 sm:top-8 translate-y-0 w-full flex basis-2/4"

  def get_classes(:avatar_container, _action), do: ""

  def get_classes(:avatar_size, :show), do: "w-32 h-32"
  def get_classes(:avatar_size, :show_catalogue), do: "w-32 h-32"
  def get_classes(:avatar_size, :show_item), do: "w-60 h-60 sm:w-64 sm:w-64"
  def get_classes(:avatar_size, _action), do: ""

  def get_classes(:avatar, :show), do: "translate-y-0 visible w-full"
  def get_classes(:avatar, :show_catalogue), do: "-translate-y-96"
  def get_classes(:avatar, :show_item), do: "translate-y-0 visible w-full"
  def get_classes(:avatar, _action), do: ""

  def get_classes(:content_container, :show), do: "basis-2/4"

  def get_classes(:content_container, :show_catalogue),
    do: "basis-full rounded-none"

  def get_classes(:content_container, :show_item), do: "basis-full"
  def get_classes(:content_container, _action), do: ""

  def get_classes(:content, :show), do: "rounded-t-5xl shadow-button"
  def get_classes(:content, :show_catalogue), do: "rounded-none"
  def get_classes(:content, :show_item), do: "rounded-t-5xl shadow-button"
  def get_classes(:content, _action), do: ""

  def get_classes(:accordion_container, :show), do: ""

  def get_classes(:accordion_container, :show_catalogue),
    do: "bg-gray-200 w-full hidden"

  def get_classes(:accordion_container, :show_item), do: ""
  def get_classes(:accordion_container, _action), do: ""

  def get_classes(:accordion, :show), do: "bg-gray-300 h-1 w-16"
  def get_classes(:accordion, :show_catalogue), do: "w-full h-1 mx-2"
  def get_classes(:accordion, :show_item), do: "bg-gray-300 h-1 w-16"
  def get_classes(:accordion, _action), do: ""
end

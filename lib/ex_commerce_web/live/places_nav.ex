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

    container_classes = get_container_classes(live_action)
    header_classes = get_header_classes(live_action)
    banner_classes = get_banner_classes(live_action)
    avatar_container_classes = get_avatar_container_classes(live_action)
    avatar_size_classes = get_avatar_size_classes(live_action)
    avatar_classes = get_avatar_classes(live_action)
    content_container_classes = get_content_container_classes(live_action)
    content_classes = get_content_classes(live_action)
    accordion_classes = get_accordion_classes(live_action)
    accordion_container_classes = get_accordion_container_classes(live_action)

    {:cont,
     socket
     |> assign(:container_classes, container_classes)
     |> assign(:header_classes, header_classes)
     |> assign(:banner_classes, banner_classes)
     |> assign(:avatar_container_classes, avatar_container_classes)
     |> assign(:avatar_size_classes, avatar_size_classes)
     |> assign(:avatar_classes, avatar_classes)
     |> assign(:content_container_classes, content_container_classes)
     |> assign(:content_classes, content_classes)
     |> assign(:accordion_container_classes, accordion_container_classes)
     |> assign(:accordion_classes, accordion_classes)}
  end

  def get_container_classes(:show), do: ""
  def get_container_classes(:show_catalogue), do: ""
  def get_container_classes(:show_item), do: ""

  def get_header_classes(:show), do: "basis-2/4 h-full -translate-y-0"
  def get_header_classes(:show_catalogue), do: "basis-none h-0 -translate-y-96"
  def get_header_classes(:show_item), do: "basis-2/4 h-full -translate-y-0"

  def get_banner_classes(:show), do: "translate-y-0"
  def get_banner_classes(:show_catalogue), do: "-translate-y-96"
  def get_banner_classes(:show_item), do: "-translate-y-96"

  def get_avatar_container_classes(:show),
    do: "absolute top-44 sm:top-60 translate-y-0 w-full flex basis-2/4"

  def get_avatar_container_classes(:show_catalogue),
    do: "absolute top-0 sm:top-60 -translate-y-96"

  def get_avatar_container_classes(:show_item),
    do: "absolute top-8 sm:top-8 translate-y-0 w-full flex basis-2/4"

  def get_avatar_size_classes(:show), do: "w-32 h-32"
  def get_avatar_size_classes(:show_catalogue), do: "w-32 h-32"
  def get_avatar_size_classes(:show_item), do: "w-60 h-60 sm:w-64 sm:w-64"

  def get_avatar_classes(:show), do: "translate-y-0 visible w-full"
  def get_avatar_classes(:show_catalogue), do: "-translate-y-96"
  def get_avatar_classes(:show_item), do: "translate-y-0 visible w-full"

  def get_content_container_classes(:show), do: "basis-2/4"

  def get_content_container_classes(:show_catalogue),
    do: "basis-full rounded-none"

  def get_content_container_classes(:show_item), do: "basis-full"

  def get_content_classes(:show), do: "rounded-t-5xl"
  def get_content_classes(:show_catalogue), do: "rounded-none"
  def get_content_classes(:show_item), do: "rounded-t-5xl"

  def get_accordion_container_classes(:show), do: ""

  def get_accordion_container_classes(:show_catalogue),
    do: "bg-gray-200 w-full hidden"

  def get_accordion_container_classes(:show_item), do: ""

  def get_accordion_classes(:show), do: "bg-gray-300 h-1 w-16"
  def get_accordion_classes(:show_catalogue), do: "w-full h-1 mx-2"
  def get_accordion_classes(:show_item), do: "bg-gray-300 h-1 w-16"
end

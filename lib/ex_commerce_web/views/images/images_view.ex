defmodule ExCommerceWeb.ImagesView do
  @moduledoc false

  alias Phoenix.{LiveComponent, LiveView}

  use ExCommerceWeb, :view

  import ExCommerceNumeric.Sizes

  def render("image", assigns) do
    opts =
      assigns
      |> Map.put_new(:size_classes, "h-32 w-32")
      |> Map.put_new(:source, "use-some-default-image.png")

    render("image.html", opts)
  end

  def render("banner", assigns) do
    opts =
      assigns
      |> Map.put_new(:source, "use-some-default-banner-image.png")
      |> Map.put_new(:size_classes, assign_size_classes(assigns[:size]))

    render("banner.html", opts)
  end

  def render(
        "upload_image_preview",
        %{
          cancel_event: _cancel_event,
          entry: %LiveView.UploadEntry{client_size: client_size} = _entry,
          target: %LiveComponent.CID{} = _target
        } = assigns
      ) do
    opts =
      assigns
      |> Map.put_new(:client_size, humanize_bytes(client_size))

    render("upload_image_preview.html", opts)
  end

  # ----------------------------------------------------------------------------
  # Private helpers
  #

  defp assign_size_classes(nil), do: "w-40 h-40"

  defp assign_size_classes(size), do: "w-#{size} h-#{size}"
end

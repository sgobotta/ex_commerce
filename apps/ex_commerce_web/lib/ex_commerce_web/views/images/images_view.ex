defmodule ExCommerceWeb.ImagesView do
  @moduledoc false

  alias Phoenix.{LiveComponent, LiveView}

  use ExCommerceWeb, :view

  import ExCommerceNumeric.Sizes

  def render("thumbnail", assigns) do
    opts =
      assigns
      |> Map.put_new(:container_classes, "")
      |> Map.put_new(:source, "use-some-default-image.png")
      |> Map.put_new(:size_classes, assign_size_classes(assigns[:size]))

    render("thumbnail.html", opts)
  end

  def render(
        "upload_image_preview",
        %{
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

  defp assign_size_classes(nil), do: ""

  defp assign_size_classes(size), do: "w-#{size} h-#{size}"
end

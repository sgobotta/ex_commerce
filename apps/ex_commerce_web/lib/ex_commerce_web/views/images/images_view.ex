defmodule ExCommerceWeb.ImagesView do
  @moduledoc false

  use ExCommerceWeb, :view

  def render("thumbnail", assigns) do
    opts =
      assigns
      |> Map.put_new(:container_classes, "")
      |> Map.put_new(:source, "use-some-default-image.png")
      |> Map.put_new(:size_classes, assign_size_classes(assigns[:size]))

    render("thumbnail.html", opts)
  end

  defp assign_size_classes(nil), do: ""

  defp assign_size_classes(size), do: "w-#{size} h-#{size}"
end

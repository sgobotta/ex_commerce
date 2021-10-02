defmodule ExCommerceWeb.SelectsView do
  @moduledoc false

  use ExCommerceWeb, :view

  def render("select", assigns) do
    opts =
      assigns
      |> Map.put_new(:use_icon, true)
      |> Map.put_new(:text, "Selected text")

    opts =
      case Map.get(opts, :use_icon) do
        false ->
          opts

        true ->
          class = """
          flex items-center justify-center
          font-semibold text-4xl
          bg-gray-200 text-black
          w-full h-full
          """

          icon_text = String.capitalize(String.first(opts.text))
          Map.put_new(opts, :icon, content_tag(:span, icon_text, class: class))
      end

    render("select.html", opts)
  end
end

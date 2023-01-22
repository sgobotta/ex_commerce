defmodule ExCommerceWeb.Components.IconComponent do
  @moduledoc """
  Wrapper for the Heroicons library
  """
  use Phoenix.Component

  attr :rest, :global,
    doc: "the arbitrary HTML attributes for the svg container",
    include: ~w(fill stroke stroke-width)

  attr :name, :atom, required: true
  attr :outline, :boolean, default: true
  attr :solid, :boolean, default: false
  attr :mini, :boolean, default: false

  def render_icon(assigns) do
    apply(Heroicons, assigns.name, [assigns])
  end
end

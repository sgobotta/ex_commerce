defmodule ExCommerceWeb.ModalComponent do
  @moduledoc false

  use ExCommerceWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div id={@id} class="phx-modal"
      phx-capture-click="close"
      phx-window-keydown="close"
      phx-key="escape"
      phx-target={"##{@id}"}
      phx-page-loading>

      <div class="phx-modal-content card">
        <%= live_close(@opts) %>
        <%= live_component module: Keyword.get(@opts, :component), opts: @opts, id: @id %>
      </div>
    </div>
    """
  end

  def live_close(opts) do
    text = raw("&times;")
    class = "close-modal-button"

    case Keyword.get(opts, :redirect_to) do
      nil ->
        live_patch(text, to: Keyword.get(opts, :return_to), class: class)

      redirect_to ->
        live_redirect(text, to: redirect_to, class: class)
    end
  end

  @impl true
  def handle_event("close", _params, socket) do
    socket =
      case Keyword.get(socket.assigns.opts, :redirect_to) do
        nil ->
          push_patch(socket, to: Keyword.get(socket.assigns.opts, :patch_to))

        redirect_to ->
          push_redirect(socket, to: redirect_to)
      end

    {:noreply, socket}
  end
end

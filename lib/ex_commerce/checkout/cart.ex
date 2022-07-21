defmodule ExCommerce.Checkout.Cart do
  @moduledoc false

  alias __MODULE__
  alias ExCommerce.Checkout.CartSupervisor

  @type state :: map() | nil

  @type t :: %__MODULE__{
          id: binary(),
          order: map() | nil,
          server: pid() | nil,
          state: state()
        }

  @enforce_keys [:id]

  defstruct id: nil, order: nil, server: nil, state: nil

  @spec generate_id(binary(), Ecto.UUID.t()) :: binary()
  def generate_id(session_id, catalogue_id) do
    :crypto.hash(:sha256, "#{session_id}+#{catalogue_id}")
    |> Base.encode16()
    |> String.downcase()
  end

  @spec new(binary()) :: t()
  def new(id) do
    %Cart{id: id}
    |> get_server()
  end

  @spec set_server(t(), pid()) :: t()
  def set_server(%Cart{} = cart, pid) do
    %Cart{cart | server: pid}
  end

  @spec set_state(t(), state()) :: t()
  def set_state(%Cart{} = cart, state) do
    %Cart{cart | state: state}
  end

  defp get_server(%Cart{id: id} = cart) do
    case CartSupervisor.get_child(CartSupervisor, id) do
      nil ->
        %Cart{cart | server: nil}

      {pid, state} ->
        %Cart{cart | server: pid, state: state}
    end
  end
end

defmodule ExCommerce.Checkout.Cart do
  @moduledoc false

  alias __MODULE__
  alias ExCommerce.Checkout.{CartServer, CartSupervisor}

  @type state :: map() | nil

  @type t :: %__MODULE__{
          id: binary(),
          order: map() | nil,
          server: pid() | nil,
          state: state()
        }

  @enforce_keys [:id]

  defstruct id: nil, order: nil, server: nil, state: nil

  @doc """
  Given a sesion id and a catalogue id, generates an id to create new
  `#{__MODULE__} structs.

  ## Examples:

      iex> generate_id("123", "456")
      "caf6c585d9ba724539d27b301a5ebd22e904fa5023cc1f888adc13529898e5ea"

  """
  @spec generate_id(binary(), Ecto.UUID.t()) :: binary()
  def generate_id(session_id, catalogue_id) do
    :crypto.hash(:sha256, "#{session_id}+#{catalogue_id}")
    |> Base.encode16()
    |> String.downcase()
  end

  @doc """
  Given an id, returns a new #{__MODULE__} struct.

  ## Examples:

      iex> new(generate_id("123", "456"))
      %ExCommerce.Checkout.Cart{
        id: "caf6c585d9ba724539d27b301a5ebd22e904fa5023cc1f888adc13529898e5ea",
        order: nil,
        server: nil,
        state: nil
      }

  """
  @spec new(binary()) :: t()
  def new(id) do
    %Cart{id: id}
    |> maybe_get_server()
  end

  @doc """
  Given a #{__MODULE__} struct and a CartServer pid returns a new #{__MODULE__}
  with a server `pid`.

  ## Examples:

      iex> set_server(%Cart{}, self())
      %ExCommerce.Checkout.Cart{
        id: "caf6c585d9ba724539d27b301a5ebd22e904fa5023cc1f888adc13529898e5ea",
        order: nil,
        server: #PID<0.863.0>,
      }

  """
  @spec set_server(t(), pid()) :: t()
  def set_server(%Cart{} = cart, pid) do
    %Cart{cart | server: pid}
  end

  @doc """
  Given a #{__MODULE__} struct and a state, returns a new #{__MODULE__} with
  `state`.

  ## Examples:

      iex> set_state(%Cart{}, %{some: "value"})
      %ExCommerce.Checkout.Cart{
        id: "caf6c585d9ba724539d27b301a5ebd22e904fa5023cc1f888adc13529898e5ea",
        order: nil,
        server: nil,
        state: %{some: "value"}
      }

  """
  @spec set_state(t(), state()) :: t()
  def set_state(%Cart{} = cart, state) do
    %Cart{cart | state: state}
  end

  @doc """
  Given a #{__MODULE__} struct and an OrderItem, updates the Cart order with the
  order item to return a new #{__MODULE__} struct.

  ## Examples:

      iex> add_to_order(%Cart{}, %{id: "some id})
      %Cart{order: %{order_items: [%{id: "some id}]]}

  """
  @spec add_to_order(t(), map()) :: t()
  def add_to_order(%Cart{order: _order} = cart, order_item) do
    %Cart{server: server} = cart = maybe_start_server(cart)

    order = CartServer.get_order(server)

    # TODO: Add item to %Order{}
    order_items = Map.get(order, :order_items, [])
    order = Map.put(order, :order_items, order_items ++ [order_item])

    :ok = CartServer.set_order(server, order)

    %Cart{cart | order: order}
  end

  defp maybe_start_server(%Cart{id: id} = cart) do
    case maybe_get_server(cart) do
      %Cart{server: nil} ->
        {:ok, server_pid} = CartSupervisor.start_child(CartSupervisor, id: id)
        %Cart{cart | server: server_pid}

      %Cart{} = cart ->
        cart
    end
  end

  defp maybe_get_server(%Cart{id: id} = cart) do
    case CartSupervisor.get_child(id) do
      nil ->
        %Cart{cart | server: nil}

      {pid, state} ->
        # Send tick to pid
        %Cart{cart | server: pid, state: state}
    end
  end
end

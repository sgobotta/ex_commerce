defmodule ExCommerce.Checkout.Cart do
  @moduledoc false

  alias __MODULE__
  alias ExCommerce.Checkout
  alias ExCommerce.Checkout.{CartServer, CartSupervisor, Order, OrderItem}

  @type state :: map() | nil

  @type t :: %__MODULE__{
          id: binary(),
          order: Order.t() | nil,
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
  def set_server(%Cart{} = cart, pid), do: %Cart{cart | server: pid}

  @doc """
  Given a #{__MODULE__} struct and an #{Order}, returns a new #{__MODULE__}
  with an updated order.

  ## Examples:

      iex> update_order(%Cart{}, %Order{buyer_name: "Some name"})
      %ExCommerce.Checkout.Cart{
        id: "caf6c585d9ba724539d27b301a5ebd22e904fa5023cc1f888adc13529898e5ea",
        order: %Order{buyer_name: "Some name"},
        server: nil,
        state: nil
      }

  """
  @spec set_order(t(), Order.t()) :: t()
  def set_order(%Cart{} = cart, %Order{} = order) do
    %Cart{server: server} = cart = maybe_start_server(cart)

    %Order{} =
      order =
      CartServer.get_order(server)
      |> Map.merge(order)

    :ok = CartServer.set_order(server, order)

    %Cart{cart | order: order}
  end

  @doc """
  Given a #{Cart} returns the current #{Order}.
  """
  @spec get_order(Cart.t()) :: Order.t()
  def get_order(%Cart{} = cart) do
    %Cart{server: server} = maybe_start_server(cart)
    CartServer.get_order(server)
  end

  @doc """
  Given a #{__MODULE__} struct and an OrderItem, updates the Cart order with the
  order item to return a new #{__MODULE__} struct.

  ## Examples:

      iex> add_to_order(%Cart{}, %{id: "some id})
      %Cart{order: %Order{order_items: [%{id: "some id}]]}

  """
  @spec add_to_order(t(), OrderItem.t()) :: t()
  def add_to_order(%Cart{} = cart, %OrderItem{} = order_item) do
    %Cart{server: server} = cart = maybe_start_server(cart)

    %Order{order_items: order_items} = order = CartServer.get_order(server)

    %Order{} =
      order =
      Map.put(
        order,
        :order_items,
        order_items ++
          [
            Checkout.preload_order_item(order_item,
              catalogue_item: [:photos],
              variant: []
            )
          ]
      )

    :ok = CartServer.set_order(server, order)

    %Cart{cart | order: order}
  end

  @doc """
  Given a #{__MODULE__} and an id, removes an #{OrderItem} from the #{Order} if
  it exists.

  ### Examples:

      iex> remove_from_order(%Cart{order: %{Order{order_items: [%OrderItem{temp_id: "123"}]}}}, "123")
      %Cart{order: %Order{order_items: []}}
      iex> remove_from_order(%Cart{order: %{Order{order_items: [%OrderItem{temp_id: "123"}]}}}, "456")
      %Cart{order: %Order{order_items: [%OrderItem{temp_id: "123"}]}}

  """
  @spec remove_from_order(t(), String.t()) :: t()
  def remove_from_order(
        %Cart{order: %Order{order_items: order_items} = order} = cart,
        temp_id
      ) do
    %Cart{server: server} = cart = maybe_start_server(cart)

    order_items =
      Enum.filter(
        order_items,
        fn
          %OrderItem{temp_id: ^temp_id} -> false
          %OrderItem{} -> true
        end
      )

    %Order{} = order = %Order{order | order_items: order_items}

    :ok = CartServer.set_order(server, order)

    %Cart{cart | order: order}
  end

  defp maybe_start_server(%Cart{id: id} = cart) do
    case maybe_get_server(cart) do
      %Cart{server: nil} ->
        args = [id: id, order: create_initial_order()]
        {:ok, server_pid} = CartSupervisor.start_child(CartSupervisor, args)
        %Cart{cart | server: server_pid}

      %Cart{} = cart ->
        # TODO: ping the server
        cart
    end
  end

  defp maybe_get_server(%Cart{id: id} = cart) do
    case CartSupervisor.get_child(id) do
      nil ->
        %Cart{cart | server: nil, order: create_initial_order()}

      {pid, state} ->
        # Send tick to pid
        %Order{} = order = CartServer.get_order(pid)
        %Cart{cart | server: pid, state: state, order: order}
    end
  end

  def create_initial_order, do: %Order{}
end

defmodule ExCommerce.Checkout.Cart do
  @moduledoc false

  alias __MODULE__
  alias ExCommerce.Checkout
  alias ExCommerce.Checkout.{Cart, CartServer, CartSupervisor}

  @type state :: map() | nil

  @type t :: %__MODULE__{
          id: binary(),
          order: Cart.Order.t() | nil,
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
  Given a #{__MODULE__} struct and an #{Cart.Order}, returns a new
  #{__MODULE__} with an updated order.

  ## Examples:

      iex> set_order(%Cart{}, %Cart.Order{buyer_name: "Some name"})
      %ExCommerce.Checkout.Cart{
        id: "caf6c585d9ba724539d27b301a5ebd22e904fa5023cc1f888adc13529898e5ea",
        order: %Cart.Order{buyer_name: "Some name"},
        server: nil,
        state: nil
      }

  """
  @spec set_order(t(), Cart.Order.t()) :: t()
  def set_order(%Cart{} = cart, %Cart.Order{} = order) do
    %Cart{server: server} = cart = maybe_start_server(cart)

    %Cart.Order{} =
      order =
      CartServer.get_order(server)
      |> Map.merge(order)

    :ok = CartServer.set_order(server, order)

    %Cart{cart | order: order}
  end

  @doc """
  Given a #{Cart} returns the current #{Cart.Order}.
  """
  @spec get_order(Cart.t()) :: Cart.Order.t()
  def get_order(%Cart{} = cart) do
    %Cart{server: server} = maybe_start_server(cart)
    CartServer.get_order(server)
  end

  @doc """
  Given a #{__MODULE__} struct and an Cart.OrderItem, updates the Cart order
  with the order item to return a new #{__MODULE__} struct.

  ## Examples:

      iex> add_to_order(%Cart{}, %{id: "some id})
      %Cart{order: %Cart.Order{order_items: [%{id: "some id}]]}

  """
  @spec add_to_order(t(), Cart.OrderItem.t()) :: t()
  def add_to_order(%Cart{} = cart, %Cart.OrderItem{} = order_item) do
    %Cart{server: server} = cart = maybe_start_server(cart)

    %Cart.Order{order_items: order_items} = order = CartServer.get_order(server)

    %Cart.Order{} =
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
      |> update_order_price()

    :ok = CartServer.set_order(server, order)

    %Cart{cart | order: order}
  end

  @doc """
  Given a #{__MODULE__} and an id, removes an #{Cart.OrderItem} from the
  #{Cart.Order} if it exists.

  ### Examples:

      iex> remove_from_order(%Cart{order: %{Cart.Order{order_items: [%Cart.OrderItem{temp_id: "123"}]}}}, "123")
      %Cart{order: %Cart.Order{order_items: []}}
      iex> remove_from_order(%Cart{order: %{Cart.Order{order_items: [%Cart.OrderItem{temp_id: "123"}]}}}, "456")
      %Cart{order: %Cart.Order{order_items: [%Cart.OrderItem{temp_id: "123"}]}}

  """
  @spec remove_from_order(t(), String.t()) :: t()
  def remove_from_order(
        %Cart{order: %Cart.Order{order_items: order_items} = order} = cart,
        temp_id
      ) do
    %Cart{server: server} = cart = maybe_start_server(cart)

    order_items =
      Enum.filter(
        order_items,
        fn
          %Cart.OrderItem{temp_id: ^temp_id} -> false
          %Cart.OrderItem{} -> true
        end
      )

    %Cart.Order{} =
      order =
      %Cart.Order{order | order_items: order_items}
      |> update_order_price()

    :ok = CartServer.set_order(server, order)

    %Cart{cart | order: order}
  end

  @doc """
  Given a #{Cart} struct, returns the sum of items present in the order.
  """
  @spec get_order_price(Cart.t()) :: Decimal.t()
  def get_order_price(%Cart{order: %Cart.Order{} = order}) do
    # TODO: Should just retrieve the price from the Order struct.
    calculate_price(order)
  end

  @spec update_order_price(Cart.Order.t()) :: Cart.Order.t()
  defp update_order_price(%Cart.Order{} = order),
    do: %Cart.Order{order | price: calculate_price(order)}

  @spec calculate_price(Cart.Order.t()) :: Decimal.t()
  defp calculate_price(%Cart.Order{} = order),
    do: Cart.Order.calculate_price(order)

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
        %Cart.Order{} = order = CartServer.get_order(pid)
        %Cart{cart | server: pid, state: state, order: order}
    end
  end

  def create_initial_order, do: %Cart.Order{}
end

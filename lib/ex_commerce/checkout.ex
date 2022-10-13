defmodule ExCommerce.Checkout do
  @moduledoc """
  The Checkout context.
  """

  import Ecto.Query, warn: false

  alias ExCommerce.Checkout.{Cart, Order, OrderItem, Supervisor}
  alias ExCommerce.Repo

  defdelegate child_spec(init_arg), to: Supervisor

  # ---------------------------------------------------------------------------
  # Checkout APIs
  #

  @doc """
  Given a #{Cart} and an #{OrderItem}, adds the `order_item` to return a new
  #{Cart}.
  """
  @spec add_to_order(Cart.t(), Ecto.Changeset.t()) :: Cart.t()
  def add_to_order(%Cart{} = cart, %Ecto.Changeset{} = order_item) do
    with price <- OrderItem.get_total_price(order_item),
         %Ecto.Changeset{changes: changes, data: data} <-
           __MODULE__.change_order_item(order_item, %{price: price}),
         %OrderItem{} = order_item <- Map.merge(data, changes) do
      Cart.add_to_order(cart, order_item)
    end
  end

  @doc """
  Given a #{Cart} validates the are order items in the #{Order} to checkout.
  """
  @spec valid_checkout?(Cart.t()) :: boolean()
  def valid_checkout?(%Cart{order: %Order{order_items: order_items}}) do
    length(order_items) > 0
  end

  @doc """
  Given a #{Cart} returns the amount of totals items in the current #{Order}.
  """
  @spec get_order_items(Cart.t()) :: non_neg_integer()
  def get_order_items(%Cart{order: %Order{order_items: order_items}}) do
    order_items
    |> Enum.reduce(0, fn %OrderItem{quantity: quantity}, acc ->
      acc + quantity
    end)
  end

  @doc """
  Given a #{Cart} returns the total price of the current #{Order}.
  """
  @spec get_order_price(Cart.t()) :: ExCommerceNumeric.t()
  def get_order_price(%Cart{order: %Order{order_items: order_items}}) do
    order_items
    |> Enum.reduce(0, fn %OrderItem{price: price}, acc ->
      ExCommerceNumeric.add(acc, price)
    end)
  end

  # ---------------------------------------------------------------------------
  # Data Access layer
  #

  @doc """
  Returns the list of order_items.

  ## Examples

      iex> list_order_items()
      [%OrderItem{}, ...]

  """
  @spec list_order_items() :: [OrderItem.t()]
  def list_order_items do
    Repo.all(OrderItem)
  end

  @doc """
  Gets a single order_item.

  Raises `Ecto.NoResultsError` if the Order item does not exist.

  ## Examples

      iex> get_order_item!(123)
      %OrderItem{}

      iex> get_order_item!(456)
      ** (Ecto.NoResultsError)

  """
  @spec get_order_item!(binary()) :: OrderItem.t()
  def get_order_item!(id), do: Repo.get!(OrderItem, id)

  @doc """
  Creates a order_item.

  ## Examples

      iex> create_order_item(%{field: value})
      {:ok, %OrderItem{}}

      iex> create_order_item(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_order_item(map()) ::
          {:ok, OrderItem.t()} | {:error, Ecto.Changeset.t()}
  def create_order_item(attrs \\ %{}) do
    %OrderItem{}
    |> OrderItem.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a order_item.

  ## Examples

      iex> update_order_item(order_item, %{field: new_value})
      {:ok, %OrderItem{}}

      iex> update_order_item(order_item, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_order_item(OrderItem.t(), map()) ::
          {:ok, OrderItem.t()} | {:error, Ecto.Changeset.t()}
  def update_order_item(%OrderItem{} = order_item, attrs) do
    order_item
    |> OrderItem.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a order_item.

  ## Examples

      iex> delete_order_item(order_item)
      {:ok, %OrderItem{}}

      iex> delete_order_item(order_item)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_order_item(OrderItem.t()) ::
          {:ok, OrderItem.t()} | {:error, Ecto.Changeset.t()}
  def delete_order_item(%OrderItem{} = order_item) do
    Repo.delete(order_item)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking order_item changes.

  ## Examples

      iex> change_order_item(order_item)
      %Ecto.Changeset{data: %OrderItem{}}

  """
  @spec change_order_item(OrderItem.t() | Ecto.Changeset.t(), map()) ::
          Ecto.Changeset.t()
  def change_order_item(order_item, attrs \\ %{}) do
    OrderItem.changeset(order_item, attrs)
  end

  @doc """
  Returns an #{OrderItem} with the given fields preloaded.

  ## Examples

  iex> preload_order_item(%OrderItem{}, [:catalogue_item, :variant, :order])
  %OrderItem{
    catalogue_item: %ExCommerce.Offerings.CatalogueItem{},
    variant: %ExCommerce.Offerings.CatalogueItemVariant{},
    order: %ExCommerce.Checkout.Order{}
  }

  """
  @spec preload_order_item(OrderItem.t(), [atom()] | keyword()) :: OrderItem.t()
  def preload_order_item(%OrderItem{} = order_item, []), do: order_item

  def preload_order_item(%OrderItem{} = order_item, fields),
    do: Repo.preload(order_item, fields)

  alias ExCommerce.Checkout.Order

  @doc """
  Returns the list of orders.

  ## Examples

      iex> list_orders()
      [%Order{}, ...]

  """
  @spec list_orders() :: [Order.t()]
  def list_orders do
    Repo.all(Order)
  end

  @doc """
  Gets a single order.

  Raises `Ecto.NoResultsError` if the Order does not exist.

  ## Examples

      iex> get_order!(123)
      %Order{}

      iex> get_order!(456)
      ** (Ecto.NoResultsError)

  """
  @spec get_order!(Ecto.UUID.t()) :: Order.t()
  def get_order!(id), do: Repo.get!(Order, id)

  @doc """
  Creates a order.

  ## Examples

      iex> create_order(%{field: value})
      {:ok, %Order{}}

      iex> create_order(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_order(map()) :: {:ok, Order.t()} | {:error, Ecto.Changeset.t()}
  def create_order(attrs \\ %{}) do
    %Order{}
    |> Order.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a order.

  ## Examples

      iex> update_order(order, %{field: new_value})
      {:ok, %Order{}}

      iex> update_order(order, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_order(Order.t(), map()) ::
          {:ok, Order.t()} | {:error, Ecto.Changeset.t()}
  def update_order(%Order{} = order, attrs) do
    order
    |> Order.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a order.

  ## Examples

      iex> delete_order(order)
      {:ok, %Order{}}

      iex> delete_order(order)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_order(Order.t()) ::
          {:ok, Order.t()} | {:error, Ecto.Changeset.t()}
  def delete_order(%Order{} = order) do
    Repo.delete(order)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking order changes.

  ## Examples

      iex> change_order(order)
      %Ecto.Changeset{data: %Order{}}

  """
  @spec change_order(Order.t(), map()) :: Ecto.Changeset.t()
  def change_order(%Order{} = order, attrs \\ %{}) do
    Order.changeset(order, attrs)
  end

  @doc """
  Returns an #{Order} with the given fields preloaded.

  ## Examples

      iex> preload_order(%Order{}, [:order_items])
      %Order{order_items: []}

  """
  @spec preload_order(Order.t(), [atom()]) :: Order.t()
  def preload_order(%Order{} = order, []), do: order

  def preload_order(%Order{} = order, fields), do: Repo.preload(order, fields)
end

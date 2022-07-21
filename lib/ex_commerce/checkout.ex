defmodule ExCommerce.Checkout do
  @moduledoc """
  The Checkout context.
  """

  import Ecto.Query, warn: false
  alias ExCommerce.Repo

  alias ExCommerce.Checkout.OrderItem
  alias ExCommerce.Checkout.Supervisor
  alias ExCommerce.Checkout.{Cart, CartServer, CartSupervisor}

  defdelegate child_spec(init_arg), to: Supervisor

  def add_to_order(%Cart{id: cart_id, server: nil} = cart, _order, _order_item) do
    case CartSupervisor.get_child(CartSupervisor, cart_id) do
      nil ->
        {:ok, pid} = CartSupervisor.start_child(CartSupervisor, id: cart_id)

        %Cart{} = cart = Cart.set_server(cart, pid)

        {:ok, state} = add_to_order(cart, %{order_id: Ecto.UUID.generate()})

        %Cart{} = Cart.set_state(cart, state)

      {pid, _state} ->
        %Cart{} = cart = Cart.set_server(cart, pid)

        {:ok, state} = add_to_order(cart, %{order_id: Ecto.UUID.generate()})

        %Cart{} = Cart.set_state(cart, state)
    end
  end

  def add_to_order(%Cart{id: cart_id, server: pid} = cart, _order, _order_item) do
    case Process.alive?(pid) do
      true ->
        {:ok, state} = add_to_order(cart, %{order_id: Ecto.UUID.generate()})

        %Cart{} = Cart.set_state(cart, state)

      false ->
        {:ok, pid} = CartSupervisor.start_child(CartSupervisor, id: cart_id)

        %Cart{} = cart = Cart.set_server(cart, pid)

        {:ok, state} = add_to_order(cart, %{order_id: Ecto.UUID.generate()})

        %Cart{} = Cart.set_state(cart, state)
    end
  end

  defp add_to_order(%Cart{} = cart, order) do
    CartServer.add_to_order(cart, order)
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
  def get_order_item!(id), do: Repo.get!(OrderItem, id)

  @doc """
  Creates a order_item.

  ## Examples

      iex> create_order_item(%{field: value})
      {:ok, %OrderItem{}}

      iex> create_order_item(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
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
  def delete_order_item(%OrderItem{} = order_item) do
    Repo.delete(order_item)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking order_item changes.

  ## Examples

      iex> change_order_item(order_item)
      %Ecto.Changeset{data: %OrderItem{}}

  """
  def change_order_item(%OrderItem{} = order_item, attrs \\ %{}) do
    OrderItem.changeset(order_item, attrs)
  end
end

defmodule ExCommerceNumeric do
  @moduledoc """
  `ExCommerceNumeric` is a convenience module to manage numerics such as money
  values.
  """

  require Decimal

  @round_places 2

  @doc """
  Fixed round places to use by default
  """
  @spec default_round_places :: 2
  def default_round_places, do: @round_places

  @doc """
  Fixed error message that is raised when arguments passed to format_price/2 are
  not valid.
  """
  @spec invalid_type_message :: String.t()
  def invalid_type_message, do: "Invalid price type: cannot convert to Decimal."

  @doc """
  Given a numeric `value` of the available forms (`String.t()`, `integer()`,
  `float()`) and some `opts` options, formats and returns the value into a
  `Decimal` struct.

  If `value` is not a valid numeric field an `ArgumentError` is raised.

  ## Examples:

      ExCommerceNumeric.format_price("100.1")
      #Decimal<100.10>
      ExCommerceNumeric.format_price("100", rounded_places: 3)
      #Decimal<100.000>

  """
  @spec format_price(binary() | integer() | float() | %Decimal{},
          round_places: integer()
        ) ::
          %Decimal{}
  def format_price(value, opts \\ []) do
    [round_places: round_places] =
      _opts =
      opts
      |> Keyword.put_new(:round_places, default_round_places())

    parse_price(value)
    |> Decimal.round(round_places)
  end

  defp parse_price(value) when Decimal.is_decimal(value), do: value

  defp parse_price(value) when is_float(value), do: Decimal.from_float(value)

  defp parse_price(value) when is_integer(value), do: Decimal.new(value)

  defp parse_price(value) when is_binary(value) do
    {decimal_value, _rest} = Decimal.parse(value)
    decimal_value
  rescue
    _error ->
      raise_invalid_price_type()
  end

  defp parse_price(_value), do: raise_invalid_price_type()

  defp raise_invalid_price_type do
    raise ArgumentError, message: invalid_type_message()
  end
end

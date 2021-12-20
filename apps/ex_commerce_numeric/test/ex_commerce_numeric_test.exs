defmodule ExCommerceNumericTest do
  @moduledoc false

  use ExUnit.Case

  alias ExCommerceNumeric

  doctest ExCommerceNumeric

  describe "format_price/2" do
    @default_round_places ExCommerceNumeric.default_round_places()
    @three_decimal_places 3

    setup do
      # #Decimal<100.00>
      decimal = Decimal.round(Decimal.from_float(100.00), @default_round_places)

      %{decimal: decimal}
    end

    test "A numeric string is formatted to Decimal", %{decimal: decimal} do
      assert ExCommerceNumeric.format_price("100.00") == decimal
    end

    test "A numeric integer is formatted to Decimal", %{decimal: decimal} do
      assert ExCommerceNumeric.format_price(100) == decimal
    end

    test "A numeric float is formatted to Decimal", %{decimal: decimal} do
      assert ExCommerceNumeric.format_price(100.0) == decimal
    end

    test "A Decimal string is kept as a decimal", %{decimal: decimal} do
      assert ExCommerceNumeric.format_price(Decimal.new("100.00")) == decimal
    end

    test "A Decimal integer is kept as a decimal", %{decimal: decimal} do
      assert ExCommerceNumeric.format_price(Decimal.new("100")) == decimal
    end

    test "A Decimal float is kept as a decimal", %{decimal: decimal} do
      assert ExCommerceNumeric.format_price(Decimal.from_float(100.0)) ==
               decimal
    end

    test "An alphanumeric string raises an ArgumentError" do
      message = ExCommerceNumeric.invalid_type_message()

      assert_raise ArgumentError, message, fn ->
        ExCommerceNumeric.format_price("usd100")
      end
    end
  end

  describe "rounded options" do
    setup do
      # #Decimal<101.000>
      with_places_decimal =
        Decimal.from_float(101.00)
        |> Decimal.round(@three_decimal_places)

      %{with_places_decimal: with_places_decimal}
    end

    test "A numeric string is parsed with rounded options", %{
      with_places_decimal: with_places_decimal
    } do
      assert ExCommerceNumeric.format_price("101.00", round_places: 3) ==
               with_places_decimal
    end

    test "A numeric integer is parsed with rounded options", %{
      with_places_decimal: with_places_decimal
    } do
      assert ExCommerceNumeric.format_price(101, round_places: 3) ==
               with_places_decimal
    end

    test "A numeric float is parsed with rounded options", %{
      with_places_decimal: with_places_decimal
    } do
      assert ExCommerceNumeric.format_price(101.0, round_places: 3) ==
               with_places_decimal
    end

    test "A decimal is parsed with rounded options", %{
      with_places_decimal: with_places_decimal
    } do
      assert ExCommerceNumeric.format_price(
               Decimal.from_float(101.0),
               round_places: 3
             ) == with_places_decimal
    end
  end
end

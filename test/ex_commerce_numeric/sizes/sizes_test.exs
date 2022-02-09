defmodule ExCommerceNumeric.SizesTest do
  @moduledoc false

  use ExUnit.Case

  alias ExCommerceNumeric.Sizes

  doctest ExCommerceNumeric.Sizes

  describe "humanize_bytes/2" do
    test "An integer with mroe than 6 digits is converted into Megabytes" do
      assert Sizes.humanize_bytes(1_667_776) == "1.67 MB."
    end

    test "An integer with mroe than 6 digits is converted into kilobytes" do
      assert Sizes.humanize_bytes(667_776) == "652 KB."
    end
  end
end

defmodule ExCommerce.RuntimeCase do
  @moduledoc """
  This module defines helpers for tests that require runtime tuning.
  """

  use ExUnit.CaseTemplate

  using(opts) do
    quote do
      opts = unquote(opts)
      @ratio_modifier Keyword.get(opts, :ratio)

      @doc """
      Convenience function used to minimize test duration while preserving
      time interval lapses.

      Given a value, returns `value` multiplied by #{@ratio_modifier}.
      """
      @spec ratio(integer) :: integer()
      def ratio(value), do: floor(:timer.seconds(value) * @ratio_modifier)

      @doc """
      Given a value, applies `value` to `ratio/1` to sleep for a period of time.
      """
      @spec sleep_with_ratio(integer()) :: :ok
      def sleep_with_ratio(interval), do: :timer.sleep(ratio(interval))
    end
  end
end

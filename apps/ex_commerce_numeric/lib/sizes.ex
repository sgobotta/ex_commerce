defmodule ExCommerceNumeric.Sizes do
  @moduledoc """
  `Sizes` is a convenience module to humanize values representing sizes.
  """

  @doc """
  Given a value in bytes, returns a string representing kbs or mbs.

  ## Examples:

      iex> Sizes.humanize_bytes(1667776)
      "1.67 MB."

      iex> Sizes.humanize_bytes(667776)
      "652 KB.

  """
  @spec humanize_bytes(integer()) :: binary()
  def humanize_bytes(size) do
    case length(Integer.digits(size)) do
      length when length > 6 ->
        "#{Float.round(size / 1_000_000, 2)} MB."

      _length ->
        "#{round(size / 1024)} KB."
    end
  end
end

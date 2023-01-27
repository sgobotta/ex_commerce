defmodule ExCommerce.QrCodes do
  @moduledoc """
  Convenience module for generating qr codes
  """

  defdelegate encode(content), to: QRCodeEx

  defdelegate svg(content, opts \\ []), to: QRCodeEx

  defdelegate png(content, opts \\ []), to: QRCodeEx
end

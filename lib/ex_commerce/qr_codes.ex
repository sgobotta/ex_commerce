defmodule ExCommerce.QrCodes do
  @moduledoc """
  Convenience module for generating qr codes
  """

  @type encode_args :: map()
  @type decode_args :: binary()
  @type encoded_content :: binary()
  @type decoded_content :: map()
  @type decode_error :: {:error, :decode_error, String.t()}
  @type decode_result :: {:ok, decoded_content()} | decode_error()

  defdelegate encode(content), to: QRCodeEx

  defdelegate svg(content, opts \\ []), to: QRCodeEx

  defdelegate png(content, opts \\ []), to: QRCodeEx

  @doc """
  Given a map encodes it's content to return a base64 string.
  """
  @spec encode_args!(encode_args()) :: encoded_content()
  def encode_args!(args), do: Jason.encode!(args) |> Base.encode64()

  @doc """
  Given a base64 encoded string, returns the decoded map result.
  """
  @spec decode_args(decode_args()) :: decode_result()
  def decode_args(args) do
    with {:ok, decoded_args} <- decode_base64(args) do
      decode_json(decoded_args)
    end
  end

  @spec decode_base64(encoded_content()) :: {:ok, binary()} | decode_error()
  defp decode_base64(args) do
    case Base.decode64(args) do
      {:ok, _decoded_args} = result ->
        result

      :error ->
        {:error, :decode_error, "Could not decode from base64"}
    end
  end

  @spec decode_json(binary()) :: {:ok, decoded_content()} | decode_error()
  defp decode_json(args) do
    case Jason.decode(args) do
      {:ok, _decoded_args} = result ->
        result

      {:error, %Jason.DecodeError{} = error} ->
        {:error, :decode_error,
         "Could not decode to json error=#{inspect(error, pretty: true)}"}
    end
  end
end

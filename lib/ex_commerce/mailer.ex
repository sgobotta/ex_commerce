defmodule ExCommerce.Mailer do
  @moduledoc """
  Responsible for configuring the Mailer module
  """
  use Swoosh.Mailer, otp_app: :ex_commerce
end

defmodule ExCommerce.Email do
  @moduledoc """
  Responsible for sending emails
  """
  import Swoosh.Email

  def new(to, body, subject) do
    new()
    |> to(to)
    |> from({from_name(), from_email()})
    |> subject(subject)
    |> text_body(body)
  end

  defp from_email, do: fetch_env!(:from_email)

  defp from_name, do: fetch_env!(:from_name)

  defp fetch_env!(key), do: Application.fetch_env!(:ex_commerce, key)
end

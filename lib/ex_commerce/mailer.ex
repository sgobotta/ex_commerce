defmodule ExCommerce.Mailer do
  @moduledoc """
  Responsible for configuring the Mailer module
  """
  use Bamboo.Mailer, otp_app: :ex_commerce
end

defmodule ExCommerce.Email do
  @moduledoc """
  Responsible for sending emails
  """
  import Bamboo.Email

  def new(to, body, subject) do
    new_email(
      to: to,
      from: Application.fetch_env!(:ex_commerce, :from_email),
      subject: subject,
      text_body: body
    )
  end
end

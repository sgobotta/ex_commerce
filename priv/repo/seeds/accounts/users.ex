defmodule ExCommerce.Seeds.Accounts.Users do
  @moduledoc """
  Seeds for the User model
  """

  use ExCommerce.Seeds.Utils,
    repo: ExCommerce.Repo,
    json_file_path: "accounts/users.json",
    plural_element: "users",
    element_module: ExCommerce.Accounts.User,
    date_keys: [:confirmed_at, :inserted_at, :updated_at]
end

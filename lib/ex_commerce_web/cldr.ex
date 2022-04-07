defmodule ExCommerceWeb.Cldr do
  @moduledoc """
  Module configuration for Cldr. See https://hexdocs.pm/ex_cldr/readme.html#backend-module-configuration
  """
  use Cldr,
    default_locale: "en",
    locales: ["en", "es"],
    add_fallback_locales: false,
    gettext: ExCommerceWeb.Gettext,
    data_dir: "./priv/cldr",
    otp_app: :ex_commerce,
    precompile_number_formats: ["¤¤#,##0.##"],
    precompile_transliterations: [],
    providers: [Cldr.Number],
    generate_docs: true,
    force_locale_download: Mix.env() == :prod
end

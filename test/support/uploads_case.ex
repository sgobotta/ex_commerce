defmodule ExCommerceWeb.UploadsCase do
  @moduledoc """
  This module defines test case helpers to be used for uploads
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      import Plug.Conn
      import Phoenix.LiveViewTest

      def valid_uploads_metadata do
        [
          %{
            last_modified: 1_594_171_879_000,
            name: "avatar-512x512.png",
            content:
              File.read!(
                Path.join(
                  Application.app_dir(:ex_commerce, "priv/static/images"),
                  "/placeholders/avatar-512x512.png"
                )
              ),
            type: "image/png"
          }
        ]
      end

      def upload_photos(
            view,
            form,
            form_attr,
            uploads_metadata,
            cancel_event_name
          ) do
        photos = file_input(view, form, form_attr, uploads_metadata)

        view =
          Enum.reduce(uploads_metadata, view, fn %{name: name}, view ->
            render_upload(photos, name, 100)
          end)

        for %{name: name} <- uploads_metadata do
          assert view =~
                   "<p class=\"text-base font-mono truncate\">\n#{name}\n    </p>"

          assert view =~
                   "<a class=\"mini-cancel-button\" href=\"#\" phx-click=\"#{cancel_event_name}\""

          assert view =~
                   "\n      &amp;times\n    </a></div><div class=\"\n    col-span-8 sm:col-span-4 row-span-1\n    px-5 sm:px-0\n    sm:text-center\n  \"><progress max=\"100\" value=\"100\"></progress>"
        end

        :ok
      end
    end
  end
end

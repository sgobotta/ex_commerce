defmodule ExCommerce.Release do
  @moduledoc """
  Used for executing DB release tasks when run in production without Mix
  installed.
  """
  require Logger

  @app :ex_commerce

  def create_db do
    load_app()

    for repo <- repos() do
      Application.fetch_env!(@app, repo)
      |> repo.__adapter__().storage_up()
      |> case do
        :ok ->
          :ok = Logger.info("Database has been created")

        {:error, :already_up} ->
          :ok = Logger.info("Database is already up")

        {:error, error} ->
          :ok =
            Logger.error(
              "Error while trying to create database: #{inspect(error)}"
            )
      end
    end
  end

  def migrate do
    :ok = load_app()

    for repo <- repos() do
      if Application.fetch_env!(@app, repo)[:ssl] do
        {:ok, _apps} = Application.ensure_all_started(:ssl)
      end

      {:ok, _, _} =
        Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end
  end

  def rollback(repo, version) do
    load_app()

    {:ok, _, _} =
      Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, to: version))
  end

  defp repos do
    Application.fetch_env!(@app, :ecto_repos)
  end

  defp load_app do
    Application.load(@app)
  end
end

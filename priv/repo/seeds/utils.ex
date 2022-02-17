defmodule ExCommerce.Seeds.Utils do
  @moduledoc """
  Utils for the ExCommerce seeds
  """

  @doc """
  Given a stringified date, casts it to a naive date time type.
  """
  @spec date_to_naive_datetime(binary()) :: nil | NaiveDateTime.t()
  def date_to_naive_datetime("NULL"), do: nil
  def date_to_naive_datetime(datetime) do
    {:ok, naive_datetime} = Ecto.Type.cast(:naive_datetime, datetime)
    naive_datetime
  end

  @doc """
  Given a map and a list of date keys, replaces existing date keys with a parsed
  value in the naive date time type to return a new map.
  """
  @spec dates_to_naive_datetime(map(), list(atom())) :: map()
  def dates_to_naive_datetime(map, keys) do
    Enum.reduce(keys, %{}, fn (key, acc) ->
      Map.put(acc, key, date_to_naive_datetime(Map.get(map, key)))
    end)
  end

  defmacro __using__(opts) do
    quote do
      alias ExCommerce.Seeds.Utils

      require Logger

      [
        repo: repo,
        json_file: json_file,
        plural_element: plural_element,
        element_module: element_module,
        date_keys: date_keys
      ] = unquote(opts)

      @json_file json_file
      @plural_element plural_element
      @element_module element_module
      @date_keys date_keys

      @repo repo

      @doc """
      Given a json file dir, inserts all elements in the database for the given
      module schema.
      """
      @spec populate :: :ok
      def populate do
        with {:ok, body} <- File.read(@json_file),
          {:ok, elements} <- Jason.decode(body, keys: :atoms) do

          elements = for element <- elements do
            Map.merge(element, Utils.dates_to_naive_datetime(element, @date_keys))
          end

          {count, _} = @repo.insert_all(@element_module, elements)

          :ok = Logger.info("✅ Inserted #{count} #{@plural_element}.")

          :ok
        end
      end
    end
  end
end

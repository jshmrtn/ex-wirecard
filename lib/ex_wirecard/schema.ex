defmodule ExWirecard.Schema do
  @moduledoc """
  Base to add Schema
  """

  defmacro __using__(opts) do
    quote bind_quoted: [name: Keyword.fetch!(opts, :name)] do
      hrl_path = Application.app_dir(:ex_wirecard, "priv/hrl/#{name}.hrl")
      xsd_path = Application.app_dir(:ex_wirecard, "priv/xsd/#{name}.xsd")

      require Record

      for {name, fields} <- Record.extract_all(from: hrl_path) do
        nice_name =
          name
          |> Atom.to_string()
          |> String.replace(~r/-/, "_")
          |> String.to_atom()

        Record.defrecord(nice_name, name, fields)
      end

      @erlsom_model :erlsom.compile_xsd_file(xsd_path)
      def erlsom_model do
        {:ok, model} = @erlsom_model
        model
      end
    end
  end
end

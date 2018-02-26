defmodule Mix.Tasks.ExWirecard.XsdToHrl do
  @moduledoc """
  Convert all XSD Files in `priv/xsd` to HRL into `priv/hrl`.
  """
  @shortdoc "Convert XSD to HRL"

  use Mix.Task

  @xsd_dir Application.app_dir(:ex_wirecard, "priv/xsd")
  @hrl_dir Application.app_dir(:ex_wirecard, "priv/hrl")

  def run(_) do
    for xsd <- xsds() do
      hrl = hrl_path(xsd)
      IO.puts("Converting #{xsd} to #{hrl}")
      :erlsom.write_xsd_hrl_file(xsd, hrl)
    end
  end

  defp xsds do
    @xsd_dir
    |> File.ls!()
    |> Enum.map(&Path.join(@xsd_dir, &1))
  end

  defp hrl_path(xsd) do
    name = Path.basename(xsd, ".xsd")
    Path.join(@hrl_dir, name <> ".hrl")
  end
end

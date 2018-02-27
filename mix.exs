defmodule ExWirecard.MixProject do
  @moduledoc false

  use Mix.Project

  def project do
    [
      app: :ex_wirecard,
      version: "0.1.1",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      test_coverage: [tool: ExCoveralls],
      deps: deps(),
      dialyzer: [
        ignore_warnings: "dialyzer.ignore-warnings",
        plt_add_apps: [:mix]
      ],
      preferred_cli_env: [
        vcr: :test,
        "vcr.delete": :test,
        "vcr.check": :test,
        "vcr.show": :test
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp description do
    """
    API Wrapper for WireCard.
    """
  end

  defp package do
    # These are the default files included in the package
    [
      name: :ex_wirecard,
      files: ["lib", "priv/hrl", "priv/xsd", "mix.exs", "README*", "LICENSE*"],
      maintainers: ["Jonatan Männchen"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/jshmrtn/ex-wirecard"}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:tesla, "~> 0.10.0"},
      {:exvcr, "~> 0.10", only: :test},
      {:erlsom, "~> 1.4"},
      {:ex_doc, "~> 0.13", only: [:dev, :docs], runtime: false},
      {:excoveralls, "~> 0.5", only: [:dev, :test], runtime: false},
      {:inch_ex, "~> 0.5", only: [:dev, :docs], runtime: false},
      {:dialyxir, "~> 0.5", only: [:dev, :test], runtime: false},
      {:credo, "~> 0.7", only: [:dev, :test], runtime: false}
    ]
  end
end

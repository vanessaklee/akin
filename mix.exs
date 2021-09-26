defmodule Akin.Mixfile do
  use Mix.Project

  def project do
    [
      app: :akin,
      version: "0.5.0",
      elixir: "~> 1.7",
      name: "Akin",
      source_url: "https://github.com/smashedtoatoms/akin",
      homepage_url: "https://github.com/smashedtoatoms/akin",
      description: description(),
      package: package(),
      deps: deps(),
      xref: [exclude: [Unicode.Utils]],
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ]
    ]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp deps do
    [
      {:credo, "~> 1.0", only: :dev},
      {:earmark, "~> 1.3", only: :dev},
      {:excoveralls, "~> 0.10", only: :test},
      {:ex_doc, "~> 0.19", only: :dev},
      {:ex_unicode, "~> 1.0"},
      {:html_entities, "~> 0.5"},
      {:nimble_csv, "~> 1.1"},
      {:stemmer, "~> 1.0"},
      {:sweet_xml, "~> 0.7.0"},
      {:unicode_string, "~> 1.0"}
    ]
  end

  defp description do
    """
    String metrics and phonetic algorithms for Elixir.  Based Heavily on
    StringMetrics for Scala written by Rocky Madden.
    """
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      maintainers: ["Jason Legler", "Kiran Danduprolu", "Craig Waterman"],
      licenses: ["Apache 2.0"],
      links: %{
        "GitHub" => "https://github.com/smashedtoatoms/akin",
        "Docs" => "https://smashedtoatoms.github.io/akin"
      }
    ]
  end
end

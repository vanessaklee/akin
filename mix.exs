defmodule Akin.Mixfile do
  use Mix.Project

  def project do
    [
      app: :akin,
      version: "0.1.7",
      elixir: "~> 1.7",
      name: "Akin",
      source_url: "https://github.com/vanessaklee/akin",
      homepage_url: "https://github.com/vanessaklee/akin",
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
    A collection of metrics and phonetic algorithms for fuzzy string matching in Elixir.
    """
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      maintainers: ["Vanessa Lee"],
      licenses: ["Apache 2.0"],
      links: %{
        "GitHub" => "https://github.com/vanessaklee/akin"
      },
      exclude_patterns: [
        ".DS_Store",
        "config/*.secret.exs",
        ".elixir_ls/",
        ".credo.exs",
        "lib/scripts",
        "lib/scripts/*"
      ]
    ]
  end
end

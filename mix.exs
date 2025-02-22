defmodule UniqueWordsSigil.MixProject do
  use Mix.Project

  @name "Unique-Words Sigil"
  @version "0.1.0"
  @repository "https://github.com/evnp/unique_words_sigil"

  defp description() do
    "~u sigil - unique-word strings, lists, HTML classes, checked at compile time"
  end

  def project() do
    [
      app: :unique_words_sigil,
      description: description(),
      version: @version,
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      package: package(),
      docs: docs(),
      deps: deps(),

      # Docs (see https://github.com/elixir-lang/ex_doc)
      name: @name,
      source_url: @repository,
      homepage_url: @repository
    ]
  end

  defp package() do
    [
      maintainers: ["Evan Campbell Purcer"],
      licenses: ["MIT"],
      links: %{"GitHub" => @repository}
    ]
  end

  defp docs() do
    [
      main: "readme",
      logo: "unique_words_sigil.png",
      extras: ["README.md"]
    ]
  end

  defp deps() do
    [
      {:ex_doc, "~> 0.34", only: :dev, runtime: false},
      {:mix_test_watch, "~> 1.0", only: [:dev, :test], runtime: false},
    ]
  end

  def application() do
    []
  end
end

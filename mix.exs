defmodule UniqueWordsSigil.MixProject do
  use Mix.Project

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
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
    ]
  end

  defp package() do
    [
      maintainers: ["Evan Campbell Purcer"],
      licenses: ["MIT"],
      links: %{"GitHub" => @repository}
    ]
  end

  def application() do
    []
  end

  defp deps() do
    []
  end
end

defmodule Tesla.Middleware.XML.MixProject do
  use Mix.Project

  def project do
    [
      app: :tesla_middleware_xml,
      version: "2.0.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      docs: docs(),
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp description do
    """
    Tesla middleware for encoding requests and decoding responses as XML.
    """
  end

  defp package do
    [
      maintainers: ["Enrique Fernandez <efcasado@gmail.com>"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/efcasado/tesla_middleware_xml"
      }
    ]
  end

  defp docs() do
    [
      main: "readme",
      extras: ["README.md"]
    ]
  end

  defp deps do
    [
      {:tesla, "~> 1.9"},

      # xml parsers
      {:saxy, "~> 1.5", optional: true},
      {:xml_json, "~> 0.4.2", optional: true},

      # development
      {:ex_doc, "~> 0.31", only: :dev, runtime: false}
    ]
  end
end

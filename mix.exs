defmodule Tesla.Middleware.XML.MixProject do
  use Mix.Project

  def project do
    [
      app: :tesla_middleware_xml,
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
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
      {:xml_json, "~> 0.4.2"},

      # development
      {:ex_doc, "~> 0.31", only: :dev, runtime: false}
    ]
  end
end

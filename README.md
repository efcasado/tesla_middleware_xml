# Tesla XML Middleware

[![Build Status](https://github.com/efcasado/tesla_middleware_xml/actions/workflows/build.yml/badge.svg?branch=main)](https://github.com/efcasado/tesla_middleware_xml/actions/workflows/build.yml)
[![hex.pm](https://img.shields.io/hexpm/l/tesla_middleware_xml.svg)](https://hex.pm/packages/tesla_middleware_xml)
[![hex.pm](https://img.shields.io/hexpm/v/tesla_middleware_xml.svg)](https://hex.pm/packages/tesla_middleware_xml)
[![Hexdocs.pm](https://img.shields.io/badge/hex-docs-purple.svg)](https://hexdocs.pm/tesla_middleware_xml/)
[![github.com](https://img.shields.io/github/last-commit/efcasado/tesla_middleware_xml.svg)](https://github.com/efcasado/tesla_middleware_xml)

[Tesla](https://github.com/elixir-tesla/tesla) middleware for encoding requests
and decoding responses as XML.

For more information about Tesla's middleware architecture, please, check
Tesla's [official documentation](https://hexdocs.pm/tesla/readme.html#writing-middleware).

This project is heavily inspired by Tesla's built-in
[Tesla.Middleware.JSON](https://hexdocs.pm/tesla/Tesla.Middleware.JSON.html)
middleware and the heavy lifting is done by
[xml_json](https://github.com/bennyhat/xml_json).


## Installation

The package can be installed by adding `tesla_middleware_xml` to your list of
dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:tesla_middleware_xml, "~> 2.0.0"}
  ]
end
```

The docs can be found at <https://hexdocs.pm/tesla_middleware_xml>.


## Contributing

This project uses [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/)
and [Semantic Versioning](https://semver.org/). The list of supported commit
types can be found
[here](https://github.com/insurgent-lab/conventional-changelog-preset?tab=readme-ov-file#commit-types).


## Resources

- [JSON and XML conversion](https://wiki.open311.org/JSON_and_XML_Conversion/)


## Acknowledgements

- [Tesla JSON Middleware](https://github.com/elixir-tesla/tesla/blob/52bf0ff600cd452471d3fc518f53436f2e48e60f/lib/tesla/middleware/json.ex)
- [Saxy](https://github.com/qcam/saxy)
- [XmlJson](https://github.com/bennyhat/xml_json)
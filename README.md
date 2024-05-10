# Tesla XML Middleware

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
    {:tesla_middleware_xml, "~> 0.1.0"}
  ]
end
```

The docs can be found at <https://hexdocs.pm/tesla_middleware_xml>.
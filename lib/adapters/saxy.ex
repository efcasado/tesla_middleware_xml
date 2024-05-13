defmodule Tesla.Middleware.XML.Adapters.Saxy do
  @default_handler Saxy.SimpleForm.Handler
  @default_handler_opts []

  def encode(data, _opts) do
    Saxy.encode!(data)
  end

  def decode(data, opts) do
    handler = Keyword.get(opts, :convention, @default_handler)
    opts = Keyword.get(opts, :convention, @default_handler_opts)
    Saxy.parse_string(data, handler, opts)
  end
end

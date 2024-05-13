defmodule Tesla.Middleware.XML.Adapters.XmlJson do
  @default_convention Parker
  # [preserve_root: "root"]
  @default_encode_opts []
  # [preserve_root: true]
  @default_decode_opts []

  def encode(data, opts) do
    convention = Keyword.get(opts, :convention, @default_convention)
    opts = Keyword.get(opts, :convention, @default_encode_opts)
    module = Module.concat(XmlJson, convention)
    apply(module, :serialize, [data, opts])
  end

  def decode(data, opts) do
    convention = Keyword.get(opts, :convention, @default_convention)
    opts = Keyword.get(opts, :convention, @default_decode_opts)
    module = Module.concat(XmlJson, convention)
    apply(module, :deserialize, [data, opts])
  end
end

# https://github.com/elixir-tesla/tesla/blob/master/lib/tesla/middleware/json.ex
defmodule Tesla.Middleware.XML do
  @moduledoc """
  Encode requests and decode responses as XML.

  This middleware can be configured to use different engines for the encoding
  and decoding of XML requests and responses.

  Remember to add `{:saxy, "~> 1.5"}` (or another supported engine) to the
  dependencies of your project.

  If you only need to encode the request body or decode the response body,
  you can use `Tesla.Middleware.EncodeXml` or `Tesla.Middleware.DecodeXml`
  directly instead.


  ### Examples

  ```elixir
  defmodule MyClient do
    use Tesla

    plug Tesla.Middleware.XML # use default settings
    # or
    plug Tesla.Middleware.XML, engine: XmlJson, engine_opts: [convention: AwsApi]
  end
  ```

  ### Options
  - `:decode` - decoding function
  - `:decode_content_types` - list of additional decodable content-types
  - `:encode` - encoding function
  - `:encode_content_type` - content-type to be used in request header
  - `:engine` - encode/decode engine, eg. `Saxy`, `XmlJson` (defaults to `Parker`)
  - `:engine_opts` - optional engine opts
  """
  @behaviour Tesla.Middleware

  @default_content_types ["application/xml"]
  @default_encode_content_type "application/xml"
  @default_engine XmlJson

  @impl Tesla.Middleware
  def call(env, next, opts) do
    opts = opts || []

    with {:ok, env} <- encode(env, opts),
         {:ok, env} <- Tesla.run(env, next) do
      decode(env, opts)
    end
  end

  @doc """
  Encode request body as XML.

  It is also used by `Tesla.Middleware.EncodeXML`.
  """
  @spec encode(Tesla.Env.t(), keyword()) :: Tesla.Env.result()
  def encode(env, opts) do
    with true <- encodable?(env),
         {:ok, body} <- encode_body(env.body, opts) do
      {:ok,
       env
       |> Tesla.put_body(body)
       |> Tesla.put_headers([{"content-type", encode_content_type(opts)}])}
    else
      false -> {:ok, env}
      error -> error
    end
  end

  defp encode_body(%Stream{} = body, opts), do: {:ok, encode_stream(body, opts)}
  defp encode_body(body, opts) when is_function(body), do: {:ok, encode_stream(body, opts)}
  defp encode_body(body, opts), do: process(body, :encode, opts)

  defp encode_content_type(opts),
    do: Keyword.get(opts, :encode_content_type, @default_encode_content_type)

  defp encode_stream(body, opts) do
    Stream.map(body, fn item ->
      {:ok, body} = encode_body(item, opts)
      body <> "\n"
    end)
  end

  defp encodable?(%{body: nil}), do: false
  defp encodable?(%{body: body}) when is_binary(body), do: false
  defp encodable?(%{body: %Tesla.Multipart{}}), do: false
  defp encodable?(_), do: true

  @doc """
  Decode response body as XML.

  It is also used by `Tesla.Middleware.DecodeJson`.
  """
  @spec decode(Tesla.Env.t(), keyword()) :: Tesla.Env.result()
  def decode(env, opts) do
    with true <- decodable?(env, opts),
         {:ok, body} <- decode_body(env.body, opts) do
      {:ok, %{env | body: body}}
    else
      false -> {:ok, env}
      error -> error
    end
  end

  defp decodable?(env, opts), do: decodable_body?(env) && decodable_content_type?(env, opts)

  defp decodable_body?(env) do
    (is_binary(env.body) && env.body != "") ||
      (is_list(env.body) && env.body != []) ||
      is_function(env.body) ||
      is_struct(env.body, Stream)
  end

  defp decodable_content_type?(env, opts) do
    case Tesla.get_header(env, "content-type") do
      nil -> false
      content_type -> Enum.any?(content_types(opts), &String.starts_with?(content_type, &1))
    end
  end

  defp content_types(opts),
    do: @default_content_types ++ Keyword.get(opts, :decode_content_types, [])

  defp decode_body(body, opts) when is_struct(body, Stream) or is_function(body),
    do: {:ok, decode_stream(body, opts)}

  defp decode_body(body, opts), do: process(body, :decode, opts)

  defp decode_stream(body, opts) do
    Stream.map(body, fn chunk ->
      case decode_body(chunk, opts) do
        {:ok, item} -> item
        _ -> chunk
      end
    end)
  end

  defp process(data, op, opts) do
    case do_process(data, op, opts) do
      {:ok, data} -> {:ok, data}
      {:error, reason} -> {:error, {__MODULE__, op, reason}}
      {:error, reason, _pos} -> {:error, {__MODULE__, op, reason}}
    end
  rescue
    ex in Protocol.UndefinedError ->
      {:error, {__MODULE__, op, ex}}
  end

  defp do_process(data, op, opts) do
    # :encode/:decode
    if fun = opts[op] do
      fun.(data)
    else
      engine = Keyword.get(opts, :engine, @default_engine)
      opts = Keyword.get(opts, :engine_opts, [])

      adapter = Module.concat(Tesla.Middleware.XML.Adapters, engine)
      apply(adapter, op, [data, opts])
    end
  end
end

defmodule Tesla.Middleware.DecodeXml do
  @moduledoc """
  Decodes response body as XML.

  Only decodes the body if the `Content-Type` header suggests
  that the body is XML.
  """
  @behaviour Tesla.Middleware

  @impl Tesla.Middleware
  def call(env, next, opts) do
    opts = opts || []

    with {:ok, env} <- Tesla.run(env, next) do
      Tesla.Middleware.XML.decode(env, opts)
    end
  end
end

defmodule Tesla.Middleware.EncodeXml do
  @moduledoc """
  Encodes request body as XML.
  """
  @behaviour Tesla.Middleware

  @impl Tesla.Middleware
  def call(env, next, opts) do
    opts = opts || []

    with {:ok, env} <- Tesla.Middleware.XML.encode(env, opts) do
      Tesla.run(env, next)
    end
  end
end

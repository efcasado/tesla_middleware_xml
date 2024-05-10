defmodule Tesla.Middleware.XmlTest do
  use ExUnit.Case

  describe "Basics" do
    defmodule Client do
      use Tesla

      plug Tesla.Middleware.XML

      adapter fn env ->
        {status, headers, body} =
          case env.url do
            "/decode" ->
              {200, [{"content-type", "application/xml"}], "<value>123</value>"}

            "/encode" ->
              {200, [{"content-type", "application/xml"}],
               env.body |> String.replace("foo", "baz")}

            "/empty" ->
              {200, [{"content-type", "application/xml"}], nil}

            "/empty-string" ->
              {200, [{"content-type", "application/xml"}], ""}

            "/invalid-content-type" ->
              {200, [{"content-type", "text/plain"}], "hello"}

            "/invalid-xml-format" ->
              {200, [{"content-type", "application/xml"}], "<foo><bar>"}

            "/invalid-xml-encoding" ->
              {200, [{"content-type", "application/xml"}],
               <<123, 34, 102, 111, 111, 34, 58, 32, 34, 98, 225, 114, 34, 125>>}

            "/raw" ->
              {200, [], env.body}

            "/stream" ->
              list = env.body |> Enum.to_list() |> Enum.join("---")
              {200, [], list}
          end

        {:ok, %{env | status: status, headers: headers, body: body}}
      end
    end

    test "decode XML body" do
      assert {:ok, env} = Client.get("/decode")
      assert env.body == 123
    end

    test "do not decode empty body" do
      assert {:ok, env} = Client.get("/empty")
      assert env.body == nil
    end

    test "do not decode empty string body" do
      assert {:ok, env} = Client.get("/empty-string")
      assert env.body == ""
    end

    test "decode only if Content-Type is application/xml" do
      assert {:ok, env} = Client.get("/invalid-content-type")
      assert env.body == "hello"
    end

    test "encode body as XML" do
      assert {:ok, env} = Client.post("/encode", %{"foo" => "bar"})
      assert env.body == %{"baz" => "bar"}
    end

    test "do not encode nil body" do
      assert {:ok, env} = Client.post("/raw", nil)
      assert env.body == nil
    end

    test "do not encode binary body" do
      assert {:ok, env} = Client.post("/raw", "raw-string")
      assert env.body == "raw-string"
    end

    test "return error on encoding error" do
      assert {:error, {Tesla.Middleware.XML, :serialize, _}} =
               Client.post("/encode", %{pid: self()})
    end

    test "post xml stream" do
      stream = Stream.map(1..3, fn i -> %{"id" => i} end)
      assert {:ok, env} = Client.post("/stream", stream)

      assert env.body ==
               ~s|<root><id>1</id></root>\n---<root><id>2</id></root>\n---<root><id>3</id></root>\n|
    end

    test "return error when decoding invalid xml format" do
      assert {:error, {Tesla.Middleware.XML, :deserialize, _}} = Client.get("/invalid-xml-format")
    end

    test "raise error when decoding non-utf8 xml" do
      assert {:error, {Tesla.Middleware.XML, :deserialize, _}} =
               Client.get("/invalid-xml-encoding")
    end
  end

  describe "Custom content type" do
    defmodule CustomContentTypeClient do
      use Tesla

      plug Tesla.Middleware.XML, decode_content_types: ["application/x-custom-xml"]

      adapter fn env ->
        {status, headers, body} =
          case env.url do
            "/decode" ->
              {200, [{"content-type", "application/x-custom-xml"}], "<value>123</value>"}
          end

        {:ok, %{env | status: status, headers: headers, body: body}}
      end
    end

    test "decode if Content-Type specified in :decode_content_types" do
      assert {:ok, env} = CustomContentTypeClient.get("/decode")
      assert env.body == 123
    end

    test "set custom request Content-Type header specified in :encode_content_type" do
      assert {:ok, env} =
               Tesla.Middleware.XML.call(
                 %Tesla.Env{body: %{"foo" => "bar"}},
                 [],
                 encode_content_type: "application/x-other-custom-xml"
               )

      assert Tesla.get_header(env, "content-type") == "application/x-other-custom-xml"
    end
  end

  describe "EncodeXml / DecodeXml" do
    defmodule EncodeDecodeXmlClient do
      use Tesla

      plug Tesla.Middleware.DecodeXml
      plug Tesla.Middleware.EncodeXml

      adapter fn env ->
        {status, headers, body} =
          case env.url do
            "/foo2baz" ->
              {200, [{"content-type", "application/xml"}],
               env.body |> String.replace("foo", "baz")}
          end

        {:ok, %{env | status: status, headers: headers, body: body}}
      end
    end

    test "EncodeXml / DecodeXml work without options" do
      assert {:ok, env} = EncodeDecodeXmlClient.post("/foo2baz", %{"foo" => "bar"})
      assert env.body == %{"baz" => "bar"}
    end
  end

  describe "Streams" do
    test "encode stream" do
      adapter = fn env ->
        assert IO.iodata_to_binary(Enum.to_list(env.body)) ==
                 ~s|<root><id>1</id></root>\n<root><id>2</id></root>\n<root><id>3</id></root>\n|
      end

      stream = Stream.map(1..3, fn i -> %{"id" => i} end)
      Tesla.Middleware.XML.call(%Tesla.Env{body: stream}, [{:fn, adapter}], [])
    end

    test "decode stream" do
      adapter = fn _env ->
        stream = Stream.map(1..3, fn i -> ~s|<id>#{i}</id>\n| end)

        {:ok,
         %Tesla.Env{
           headers: [{"content-type", "application/xml"}],
           body: stream
         }}
      end

      assert {:ok, env} = Tesla.Middleware.XML.call(%Tesla.Env{}, [{:fn, adapter}], [])
      assert Enum.to_list(env.body) == [1, 2, 3]
    end
  end

  describe "Multipart" do
    defmodule MultipartClient do
      use Tesla

      plug Tesla.Middleware.XML

      adapter fn %{url: url, body: %Tesla.Multipart{}} = env ->
        {status, headers, body} =
          case url do
            "/upload" ->
              {200, [{"content-type", "application/xml"}], "<status>ok</status>"}
          end

        {:ok, %{env | status: status, headers: headers, body: body}}
      end
    end

    test "skips encoding multipart bodies" do
      alias Tesla.Multipart

      mp =
        Multipart.new()
        |> Multipart.add_field("param", "foo")

      assert {:ok, env} = MultipartClient.post("/upload", mp)
      assert env.body == "ok"
    end
  end
end

defmodule ExWirecard.Middleware.XML do
  @behaviour Tesla.Middleware

  alias Tesla.Middleware.Headers
  alias Tesla.Multipart

  @moduledoc """
  Encode requests and decode responses as XML.

  This middleware requires [erlsom](https://hex.pm/packages/erlsom) as dependency.

  Remember to add `{:erlsom, "~> 1.4"}` to dependencies (and `:erlsom` to applications in `mix.exs`)
  Also, you need to recompile tesla after adding `:erlsom` dependency:

  ```
  mix deps.clean ex_wirecard
  mix deps.compile ex_wirecard
  ```

  ### Example usage
  ```
  defmodule MyClient do
    use Tesla

    plug Tesla.Middleware.XML, model: :erlsom.compile_xsd_file("some.xsd")
  end
  ```

  ### Options
  - `:engine_opts` - optional engine options
  - `:decode_content_types` - list of additional decodable content-types
  - `:model` - erlsom XML Model
  """
  @default_content_types ["application/xml"]

  def call(env, next, opts) do
    opts = opts || []

    env
    |> encode(opts)
    |> Tesla.run(next)
    |> decode(opts)
  end

  @doc """
  Encode request body as XML.
  """
  def encode(env, opts) do
    if encodable?(env) do
      env
      |> Map.update!(:body, &encode_body(&1, opts))
      |> Headers.call([], %{"content-type" => "application/xml"})
    else
      env
    end
  end

  defp encode_body(%Stream{} = body, opts), do: encode_stream(body, opts)
  defp encode_body(body, opts) when is_function(body), do: encode_stream(body, opts)
  defp encode_body(body, opts), do: process(body, :encode, opts)

  defp encode_stream(body, opts) do
    Stream.map(body, fn item -> encode_body(item, opts) <> "\n" end)
  end

  defp encodable?(%{body: nil}), do: false
  defp encodable?(%{body: body}) when is_binary(body), do: false
  defp encodable?(%{body: %Multipart{}}), do: false
  defp encodable?(_), do: true

  @doc """
  Decode response body as XML.
  """
  def decode(env, opts) do
    if decodable?(env, opts) do
      Map.update!(env, :body, &process(&1, :decode, opts))
    else
      env
    end
  end

  defp decodable?(env, opts), do: decodable_body?(env) && decodable_content_type?(env, opts)

  defp decodable_body?(env) do
    (is_binary(env.body) && env.body != "") || (is_list(env.body) && env.body != [])
  end

  defp decodable_content_type?(env, opts) do
    case env.headers["content-type"] do
      nil -> false
      content_type -> Enum.any?(content_types(opts), &String.starts_with?(content_type, &1))
    end
  end

  defp content_types(opts),
    do: @default_content_types ++ Keyword.get(opts, :decode_content_types, [])

  defp process(data, op, opts) do
    with {:ok, value} <- do_process(data, op, opts) do
      value
    else
      {:error, reason} ->
        raise %Tesla.Error{message: "XML #{op} error: #{inspect(reason)}", reason: reason}

      {:error, msg, position} ->
        reason = {msg, position}
        raise %Tesla.Error{message: "XML #{op} error: #{inspect(reason)}", reason: reason}
    end
  end

  defp do_process(data, :encode, opts) do
    {:ok, encoded} = :erlsom.write(data, Keyword.fetch!(opts, :model))
    {:ok, to_string(encoded)}
  end

  defp do_process(data, :decode, opts) do
    case :erlsom.scan(data, Keyword.fetch!(opts, :model)) do
      {:ok, decoded, _} -> {:ok, decoded}
      {:error, error} -> {:error, error}
    end
  end
end

defmodule ExWirecard.Middleware.DecodeXML do
  @moduledoc """
  Decode XML
  """

  alias ExWirecard.Middleware.XML

  def call(env, next, opts) do
    opts = opts || []

    env
    |> Tesla.run(next)
    |> XML.decode(opts)
  end
end

defmodule ExWirecard.Middleware.EncodeXML do
  @moduledoc """
  Encode XML
  """

  alias ExWirecard.Middleware.XML

  def call(env, next, opts) do
    opts = opts || []

    env
    |> XML.encode(opts)
    |> Tesla.run(next)
  end
end

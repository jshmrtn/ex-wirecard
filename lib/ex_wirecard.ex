defmodule ExWirecard do
  @moduledoc """
  API Client for WireCard.
  """

  defmacro __using__(opts) do
    base_uri = Keyword.get(opts, :base_uri, "https://api.wirecard.com/engine/rest/")
    schema_module = Keyword.fetch!(opts, :schema_module)

    quote bind_quoted: [
            base_uri: base_uri,
            schema_module: schema_module
          ] do
      use Tesla

      plug(Tesla.Middleware.Headers, %{"Accept" => "application/xml"})
      @model schema_module.erlsom_model()
      plug(ExWirecard.Middleware.XML, model: @model)

      def new(opts \\ %{}) do
        Tesla.build_client([
          {Tesla.Middleware.BaseUrl,
           Application.get_env(:ex_wirecard, :base_url, unquote(base_uri))},
          {Tesla.Middleware.BasicAuth,
           Map.merge(
             %{
               username: Application.fetch_env!(:ex_wirecard, :username),
               password: Application.fetch_env!(:ex_wirecard, :password)
             },
             opts
           )}
        ])
      end
    end
  end
end

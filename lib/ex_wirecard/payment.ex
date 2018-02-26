defmodule ExWirecard.Payment do
  @moduledoc """
  Payments Endpoint Client
  """

  use ExWirecard,
    base_uri: "https://api.wirecard.com/engine/rest/",
    schema_module: ExWirecard.Schema.Payment,
    name: "payment"
end

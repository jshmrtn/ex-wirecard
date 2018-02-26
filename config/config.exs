use Mix.Config

config :exvcr,
  vcr_cassette_library_dir: "priv/fixture/vcr_cassettes",
  custom_cassette_library_dir: "priv/fixture/custom_cassettes",
  filter_sensitive_data: [
    [
      pattern: "<merchant-account-id.+</merchant-account-id>",
      placeholder: "<merchant-account-id>Foo</merchant-account-id>"
    ]
  ],
  filter_request_headers: ["authorization"]

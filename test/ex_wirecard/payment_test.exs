defmodule ExWirecard.PaymentTest do
  @moduledoc false

  use ExUnit.Case
  alias ExWirecard.Payment
  doctest Payment

  alias ExWirecard.Schema.Payment, as: PaymentSchema
  require PaymentSchema
  require Record

  use ExVCR.Mock, adapter: ExVCR.Adapter.Httpc

  setup do
    Application.put_env(:ex_wirecard, :username, System.get_env("WIRECARD_USERNAME"))
    Application.put_env(:ex_wirecard, :password, System.get_env("WIRECARD_PASSWORD"))
    Application.put_env(:ex_wirecard, :base_url, "https://api-test.wirecard.com/engine/rest/")

    :ok
  end

  @apple_pay_token "foo"

  describe "tesla configured right" do
    test "makes request" do
      use_cassette "payments" do
        body =
          PaymentSchema.payment()
          |> PaymentSchema.payment(
            "merchant-account-id":
              PaymentSchema.merchant_account_id(
                "#text": System.get_env("WIRECARD_MAID") || "set_for_re-record"
              )
          )
          |> PaymentSchema.payment("request-id": "test123")
          |> PaymentSchema.payment("transaction-type": "authorization")
          |> PaymentSchema.payment(
            "payment-methods":
              PaymentSchema.payment_methods(
                "payment-method": [
                  PaymentSchema.payment_method(name: "creditcard")
                ]
              )
          )
          |> PaymentSchema.payment(
            cryptogram:
              PaymentSchema.cryptogram(
                "cryptogram-type": "apple-pay",
                "cryptogram-value": @apple_pay_token
              )
          )

        assert %{body: body} = Payment.post(Payment.new(), "payments", body)
        assert Record.is_record(body, :payment)
      end
    end
  end
end

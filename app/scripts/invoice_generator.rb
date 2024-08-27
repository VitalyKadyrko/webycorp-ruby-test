module InvoiceGenerator
  def self.call
    Stripe.api_key = ENV['TEST_APP__STRIPE__API_KEY']
    fakestore_client = FakeStoreAPIService::Client.new
    carts = fakestore_client.get_carts_list
  end
end
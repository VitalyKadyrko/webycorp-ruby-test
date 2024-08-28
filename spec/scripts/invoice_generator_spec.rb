# frozen_string_literal: true

require 'spec_helper'
require_relative '../../app/scripts/invoice_generator'

RSpec.describe InvoiceGenerator, :vcr do
  let(:fake_store_client) { instance_double(FakeStoreAPIService::Client) }
  let(:cart) { { 'userId' => 1, 'products' => [{ 'productId' => 1, 'quantity' => 2 }] } }
  let(:user) { { 'email' => 'test@example.com', 'firstname' => 'John', 'lastname' => 'Doe' } }
  let(:product_data) { { 'title' => 'Sample Product', 'price' => 1000 } }

  let(:stripe_customer) { double('Stripe::Customer', id: 'cus_12345') }
  let(:stripe_product) { double('Stripe::Product', id: 'prod_12345') }
  let(:stripe_price) { double('Stripe::Price', id: 'price_12345') }
  let(:stripe_invoice_item) { double('Stripe::InvoiceItem', id: 'ii_12345') }
  let(:stripe_invoice) { double('Stripe::Invoice', id: 'in_12345') }

  before do
    allow(FakeStoreAPIService::Client).to receive(:new).and_return(fake_store_client)
    allow(fake_store_client).to receive(:take_carts_list).and_return([cart])
    allow(fake_store_client).to receive(:take_user).with(1).and_return(user)
    allow(fake_store_client).to receive(:take_product).with(1).and_return(product_data)

    allow(Stripe::Customer).to receive(:create).with(email: 'test@example.com',
                                                     name: 'John Doe').and_return(stripe_customer)
    allow(Stripe::Product).to receive(:create).with(name: 'Sample Product').and_return(stripe_product)
    allow(Stripe::Price).to receive(:create).with(product: 'prod_12345', currency: 'usd',
                                                  unit_amount: 1000).and_return(stripe_price)
    allow(Stripe::InvoiceItem).to receive(:create).with(customer: 'cus_12345', price: 'price_12345',
                                                        quantity: 2).and_return(stripe_invoice_item)
    allow(Stripe::Invoice).to receive(:create).with(customer: 'cus_12345',
                                                    auto_advance: false).and_return(stripe_invoice)
    allow(Stripe::Invoice).to receive(:add_lines).with('in_12345', lines: [{ invoice_item: 'ii_12345' }])
    allow(Stripe::Invoice).to receive(:finalize_invoice).with('in_12345')

    allow(Settings).to receive_message_chain(:stripe, :api_key).and_return('sk_test_123')
    allow(Application).to receive(:logger).and_return(Logger.new($stdout))
  end

  describe '.call' do
    it 'configures Stripe with the correct API key' do
      expect(Stripe).to receive(:api_key=).with('sk_test_123')
      described_class.call
    end

    it 'processes carts from FakeStoreAPI and creates invoices' do
      expect(fake_store_client).to receive(:take_carts_list).and_return([cart])
      expect(fake_store_client).to receive(:take_user).with(1).and_return(user)
      expect(fake_store_client).to receive(:take_product).with(1).and_return(product_data)

      expect(Stripe::Customer).to receive(:create).with(email: 'test@example.com',
                                                        name: 'John Doe').and_return(stripe_customer)
      expect(Stripe::Product).to receive(:create).with(name: 'Sample Product').and_return(stripe_product)
      expect(Stripe::Price).to receive(:create).with(product: 'prod_12345', currency: 'usd',
                                                     unit_amount: 1000).and_return(stripe_price)
      expect(Stripe::InvoiceItem).to receive(:create).with(customer: 'cus_12345', price: 'price_12345',
                                                           quantity: 2).and_return(stripe_invoice_item)
      expect(Stripe::Invoice).to receive(:create).with(customer: 'cus_12345',
                                                       auto_advance: false).and_return(stripe_invoice)
      expect(Stripe::Invoice).to receive(:add_lines).with('in_12345', lines: [{ invoice_item: 'ii_12345' }])
      expect(Stripe::Invoice).to receive(:finalize_invoice).with('in_12345')

      described_class.call
    end
  end
end

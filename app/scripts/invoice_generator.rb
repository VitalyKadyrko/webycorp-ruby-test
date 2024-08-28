# frozen_string_literal: true

# Module for creating an invoice based on data received from the FakeStoreAPI service
module InvoiceGenerator
  def self.call
    configure_stripe
    process_carts
  end

  private

  def self.configure_stripe
    Stripe.api_key = Settings.stripe.api_key
    Stripe.logger = Application.logger
    Stripe.log_level = Stripe::LEVEL_INFO
  end

  def self.process_carts
    fakestore_client = FakeStoreAPIService::Client.new
    carts = fakestore_client.take_carts_list

    carts.each do |cart|
      process_cart(fakestore_client, cart)
    end
  end

  def self.process_cart(fakestore_client, cart)
    customer = create_customer(fakestore_client, cart['userId'])
    invoice_items = create_invoice_items(fakestore_client, customer, cart['products'])
    invoice = create_invoice(customer.id, invoice_items)
    finalize_invoice(invoice)
  end

  def self.create_customer(fakestore_client, user_id)
    user = fakestore_client.take_user(user_id)
    Stripe::Customer.create(
      email: user['email'],
      name: "#{user['firstname']} #{user['lastname']}"
    )
  end

  def self.create_invoice_items(fakestore_client, customer, products)
    products.map do |cart_product|
      product_data = fakestore_client.take_product(cart_product['productId'])
      stripe_product = create_stripe_product(product_data['title'])
      stripe_price = create_stripe_price(stripe_product.id, product_data['price'].to_i)
      create_invoice_item(customer, stripe_price, cart_product['quantity'])
    end
  end

  def self.create_stripe_product(name)
    Stripe::Product.create(name: name)
  end

  def self.create_stripe_price(product_id, amount)
    Stripe::Price.create(
      product: product_id,
      currency: 'usd',
      unit_amount: amount
    )
  end

  def self.create_invoice_item(customer, stripe_price, quantity)
    invoice_item = Stripe::InvoiceItem.create(
      customer: customer.id,
      price: stripe_price.id,
      quantity: quantity
    )
    { invoice_item: invoice_item.id }
  end

  def self.create_invoice(customer_id, invoice_items)
    invoice = Stripe::Invoice.create(
      customer: customer_id,
      auto_advance: false
    )
    Stripe::Invoice.add_lines(invoice.id, lines: invoice_items)
    invoice
  end

  def self.finalize_invoice(invoice)
    Stripe::Invoice.finalize_invoice(invoice.id)
  end
end

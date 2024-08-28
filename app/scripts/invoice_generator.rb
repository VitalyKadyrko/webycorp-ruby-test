# frozen_string_literal: true

# Module for creating an invoice based on data received from the FakeStoreAPI service
module InvoiceGenerator
  def self.call
    set_stripe_configuration
    process_carts
  end

  def self.set_stripe_configuration
    Stripe.api_key = ENV.fetch('TEST_APP__STRIPE__API_KEY', nil)
    Stripe.logger = Application.logger
    Stripe.log_level = Stripe::LEVEL_INFO
  end

  def self.process_carts
    fakestore_client = FakeStoreAPIService::Client.new
    fakestore_client.take_carts_list.each do |cart|
      process_cart(fakestore_client, cart)
    end
  end

  def self.process_cart(fakestore_client, cart)
    customer = create_stripe_customer(fakestore_client, cart['userId'])
    invoice_items = create_invoice_items(fakestore_client, customer.id, cart['products'])
    invoice = create_invoice(customer.id, invoice_items)
    finalize_invoice(invoice.id)
  rescue StandardError => e
    Application.logger.error("Failed to process cart #{cart['id']}: #{e.message}")
  end

  def self.create_stripe_customer(fakestore_client, user_id)
    user = fakestore_client.take_user(user_id)
    Stripe::Customer.create({
                              email: user['email'],
                              name: "#{user['firstname']} #{user['lastname']}"
                            })
  end

  def self.create_invoice_items(fakestore_client, customer_id, products)
    products.map do |cart_product|
      product_data = fakestore_client.take_product(cart_product['productId'])
      stripe_product = create_stripe_product(product_data['title'])
      stripe_price = create_stripe_price(stripe_product.id, product_data['price'].to_i)

      Stripe::InvoiceItem.create({
                                   customer: customer_id,
                                   price: stripe_price.id,
                                   quantity: cart_product['quantity']
                                 }).id
    end
  end

  def self.create_invoice(customer_id, invoice_items)
    invoice = Stripe::Invoice.create({
                                       customer: customer_id,
                                       auto_advance: false
                                     })

    Stripe::Invoice.add_lines(invoice.id, { lines: invoice_items })
    invoice
  end

  def self.finalize_invoice(invoice_id)
    Stripe::Invoice.finalize_invoice(invoice_id)
  end

  def self.create_stripe_product(name)
    Stripe::Product.create({ name: name })
  end

  def self.create_stripe_price(product_id, amount)
    Stripe::Price.create({
                           product: product_id,
                           currency: 'usd',
                           unit_amount: amount
                         })
  end
end

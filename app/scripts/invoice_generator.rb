module InvoiceGenerator
  def self.call
    Stripe.api_key = ENV['TEST_APP__STRIPE__API_KEY']
    fakestore_client = FakeStoreAPIService::Client.new
    carts = fakestore_client.get_carts_list
    carts.each do |cart|
      user = fakestore_client.get_user(cart['userId'])
      customer = Stripe::Customer.create({
        email: user['email'],
        name: "#{user['firstname']} #{user['lastname']}"
      })

      cart['products'].each do |cart_product|
        product_data = fakestore_client.get_product(cart_product['productId'])

        stripe_product = Stripe::Product.create({
          name: product_data['title']
        })

        stripe_price = Stripe::Price.create({
          product: stripe_product.id,
          currency: 'usd',
          unit_amount: product_data['price']
        })

        stripe_invoice = Stripe::InvoiceItem.create({
          customer: customer.id,
          price: stripe_price.id,
          quantity: cart_product['quantity']
        })
      end

      invoice = Stripe::Invoice.create({
        customer: customer.id,
        auto_advance: false
      })
      
    end
  end
end
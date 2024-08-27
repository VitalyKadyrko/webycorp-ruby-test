require 'faraday'

module FakeStoreAPIService
  class Client

    def initialize
      @connection = Faraday.new
    end

    def get_carts_list
      response = @connection.get('https://fakestoreapi.com/carts')
      JSON.parse(response.body)
    end

    def get_user(user_id)
      response = @connection.get("https://fakestoreapi.com/users/#{user_id}")
      JSON.parse(response.body)
    end

    def get_product(product_id)
      response = @connection.get("https://fakestoreapi.com/products/#{product_id}")
      JSON.parse(response.body)
    end
  end
end
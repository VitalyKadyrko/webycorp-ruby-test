# frozen_string_literal: true

require 'faraday'

module FakeStoreAPIService
  class Client
    BASE_URL = 'https://fakestoreapi.com'

    def initialize
      @connection = Faraday.new(url: BASE_URL)
    end

    def get_carts_list
      response = @connection.get('/carts')
      JSON.parse(response.body)
    end

    def get_user(_user_id)
      response = @connection.get("users/#{user_id}")
      JSON.parse(response.body)
    end

    def get_product(_product_id)
      response = @connection.get("/products/#{product_id}")
      JSON.parse(response.body)
    end
  end
end

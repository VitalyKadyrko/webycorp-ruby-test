# frozen_string_literal: true

require 'faraday'

module FakeStoreAPIService
  # Client with methods for receiving data from FakeStoreAPI service
  class Client
    BASE_URL = 'https://fakestoreapi.com'

    def initialize
      @connection = Faraday.new(url: BASE_URL) do |faraday|
        faraday.response :logger, Application.logger, bodies: true
        faraday.adapter Faraday.default_adapter
      end
    end

    def take_carts_list
      log_request('GET', '/carts')
      response = @connection.get('/carts')
      JSON.parse(response.body)
    end

    def take_user(user_id)
      log_request('GET', "/users/#{user_id}")
      response = @connection.get("users/#{user_id}")
      JSON.parse(response.body)
    end

    def take_product(product_id)
      log_request('GET', "/products/#{product_id}")
      response = @connection.get("/products/#{product_id}")
      JSON.parse(response.body)
    end

    private

    def log_request(method, endpoint)
      Application.logger.info("FakeStoreAPI Request: #{method} #{endpoint}")
    end
  end
end

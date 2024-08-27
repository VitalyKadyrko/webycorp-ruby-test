# frozen_string_literal: true

require 'faraday'

module FakeStoreAPIService
  class Client
    BASE_URL = 'https://fakestoreapi.com'

    def initialize
      @connection = Faraday.new(url: BASE_URL) do |faraday|
        faraday.response :logger, Application.logger, bodies: true
        faraday.adapter Faraday.default_adapter
    end

    def get_carts_list
      log_request('GET', '/carts')
      response = @connection.get('/carts')
      JSON.parse(response.body)
    end

    def get_user(_user_id)
      log_request('GET', "/users/#{user_id}")
      response = @connection.get("users/#{user_id}")
      JSON.parse(response.body)
    end

    def get_product(_product_id)
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

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
  end
end
require 'faraday'

module FakeStoreAPIService
  class Client

    def initialize
      @connection = Faraday.new
    end
    
  end
end
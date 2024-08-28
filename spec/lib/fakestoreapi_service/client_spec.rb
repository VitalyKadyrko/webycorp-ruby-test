# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FakeStoreAPIService::Client, :vcr do
  let(:client) { described_class.new }

  describe '#take_carts_list' do
    it 'retrieves the list of carts' do
      VCR.use_cassette('fake_store_api/carts_list') do
        carts = client.take_carts_list
        expect(carts).to be_an(Array)
        expect(carts.first).to include('userId', 'products')
      end
    end
  end

  describe '#take_user' do
    let(:user_id) { 1 }

    it 'retrieves a user by ID' do
      VCR.use_cassette("fake_store_api/user_#{user_id}") do
        user = client.take_user(user_id)
        expect(user).to include('email', 'name')
        expect(user['email']).to match(/@/)
      end
    end
  end

  describe '#take_product' do
    let(:product_id) { 1 }

    it 'retrieves a product by ID' do
      VCR.use_cassette("fake_store_api/product_#{product_id}") do
        product = client.take_product(product_id)
        expect(product).to include('title', 'price')
        expect(product['price'].to_i).to be_a(Integer)
      end
    end
  end
end

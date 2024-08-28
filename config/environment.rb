# frozen_string_literal: true

ENV['RACK_ENV'] ||= 'development'
ENV['TZ'] = 'UTC'
ENV['TEST_APP__STRIPE__API_KEY'] =
  'sk_test_51Ps6CCLyaEMk9YEvvmHn7hqdzJc7aGStYk4Xf8rQWRYNHKKngfr6Ue4qsaXOcVOwIjfYoqdjuMuvjqJdCN3gCA4600FCc79kRx'
require 'bundler/setup'
Bundler.require(:default, ENV.fetch('RACK_ENV'))

require_relative 'application'
Application.load_app!

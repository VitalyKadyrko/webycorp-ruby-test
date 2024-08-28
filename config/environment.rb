# frozen_string_literal: true

ENV['RACK_ENV'] ||= 'development'
ENV['TZ'] = 'UTC'

require 'bundler/setup'
Bundler.require(:default, ENV.fetch('RACK_ENV'))

require_relative 'application'
Application.load_app!

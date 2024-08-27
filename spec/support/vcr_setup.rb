# frozen_string_literal: true

require 'vcr'
require 'webmock/rspec'

VCR.configure do |config|
  config.cassette_library_dir = 'spec/vcr_cassettes'
  config.hook_into :faraday
  config.configure_rspec_metadata!
  config.filter_sensitive_data('<STRIPE_API_KEY>') { ENV['TEST_APP__STRIPE__API_KEY'] }
  config.allow_http_connections_when_no_cassette = true
  config.debug_logger = $stdout
end

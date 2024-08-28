# frozen_string_literal: true

require 'vcr'

VCR.configure do |config|
  config.cassette_library_dir = 'spec/vcr_cassettes'
  config.hook_into :faraday
  config.configure_rspec_metadata!
  config.filter_sensitive_data('<STRIPE_API_KEY>') { Settings.stripe.api_key }
  config.allow_http_connections_when_no_cassette = true
  config.debug_logger = $stdout
end

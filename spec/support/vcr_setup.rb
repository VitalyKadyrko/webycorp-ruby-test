# frozen_string_literal: true

require 'vcr'

VCR.configure do |config|
  config.cassette_library_dir = 'spec/vcr_cassettes'
  config.hook_into :faraday
  config.filter_sensitive_data('<STRIPE_API_KEY>') { ENV.fetch('TEST_APP__STRIPE__API_KEY', nil) }
  config.configure_rspec_metadata!
end

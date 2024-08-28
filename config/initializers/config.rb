# frozen_string_literal: true

Config.setup do |config|
  config.use_env = true
  config.env_prefix = 'TEST_APP'
  config.env_separator = '__'

  config.schema do
    # These settings must exist in the configuration files or in the ENV environment
    required(:stripe).schema do
      required(:api_key).filled
    end
  end
end

# There is a register method in the config gem
# for Sinatra application, but it improper handles
# a symbol from the Sinatra environment method
Config.setting_files(File.expand_path('..', __dir__), Application.environment)

Config.load_and_set_settings('webycorp-ruby-test/config/settings/development.local.yml')

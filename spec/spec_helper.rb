# frozen_string_literal: true

require "simplecov"
SimpleCov.start "rails" do
  add_filter "/spec/"
  add_filter "/config/"
  add_group "Services", "app/services"
  add_group "Components", "app/components"
end

require "bundler/setup"
require "rails_db_analytics"
require "pry-byebug"
require "vcr"
require "webmock/rspec"
require "factory_bot_rails"

ENV["RAILS_ENV"] = "test"

require_relative "dummy/config/environment"
ActiveRecord::Migrator.migrations_paths = [File.expand_path("dummy/db/migrate", __dir__)]
ActiveRecord::Migrator.migrations_paths << File.expand_path("../db/migrate", __dir__)

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Include FactoryBot methods
  config.include FactoryBot::Syntax::Methods

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

VCR.configure do |config|
  config.cassette_library_dir = "spec/vcr_cassettes"
  config.hook_into :webmock
  config.configure_rspec_metadata!

  # Filter out sensitive data
  config.filter_sensitive_data("<ANTHROPIC_API_KEY>") { RailsDbAnalytics.configuration.anthropic_api_key }

  # Ignore localhost requests
  config.ignore_localhost = true
end

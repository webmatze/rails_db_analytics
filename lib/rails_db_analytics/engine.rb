# frozen_string_literal: true

module RailsDbAnalytics
  class Error < StandardError; end

  class Engine < ::Rails::Engine
    isolate_namespace RailsDbAnalytics

    initializer "rails_db_analytics.assets" do |app|
      app.config.assets.precompile += %w[
        rails_db_analytics/application.tailwind.css
        rails_db_analytics/application.js
      ]
    end

    initializer "rails_db_analytics.importmap" do |app|
      # app.config.importmap.paths += [Engine.root.join("config/importmap.rb")]
    end

    initializer "rails_db_analytics.helpers" do
      ActiveSupport.on_load(:action_controller) do
        helper RailsDbAnalytics::Engine.helpers
      end
    end

    config.generators do |g|
      g.test_framework :rspec
      g.fixture_replacement :factory_bot
      g.factory_bot dir: 'spec/factories'
    end

    config.to_prepare do
      # Load any custom report classes from the host application
      Dir.glob(Rails.root.join("app/reports/**/*_report.rb")).each do |report|
        require_dependency report
      end
    end
  end

  # Shortcut method to access the Anthropic client
  def self.anthropic_client
    configuration.anthropic_client
  end

  # Shortcut method to access the schema content
  def self.schema_content
    configuration.schema_content
  end

  # Helper method to generate a cache key for LLM responses
  def self.cache_key(description)
    configuration.cache_key(description)
  end

  # Helper method to handle LLM response caching
  def self.with_caching(description)
    return yield unless configuration.cache_responses

    key = cache_key(description)
    configuration.cache_store.fetch(key, expires_in: configuration.cache_ttl) do
      yield
    end
  end
end

# frozen_string_literal: true

module RailsDbAnalytics
  class Configuration
    attr_accessor :anthropic_api_key,
                  :llm_model,
                  :max_tokens,
                  :temperature,
                  :schema_path,
                  :cache_store,
                  :cache_responses,
                  :cache_ttl,
                  :importmap,
                  :tailwind_content

    def initialize
      @llm_model = "claude-3-sonnet-20240229"
      @max_tokens = 4096
      @temperature = 0.7
      @schema_path = Rails.root.join('db/schema.rb')
      @cache_store = Rails.cache
      @cache_responses = Rails.env.production?
      @cache_ttl = 1.hour
      @importmap = Importmap::Map.new
      @importmap.draw(Engine.root.join("config/importmap.rb"))
      @tailwind_content = [
        Engine.root.join("app/views/**/*.erb"),
        Engine.root.join("app/helpers/**/*.rb"),
        Engine.root.join("app/controllers/**/*.rb"),
        Engine.root.join("app/javascript/**/*.js"),
        Engine.root.join("app/assets/stylesheets/**/*.css")
      ]
    end

    def anthropic_client
      @anthropic_client ||= Anthropic::Client.new(
        access_token: anthropic_api_key
      )
    end

    def schema_content
      @schema_content ||= File.read(schema_path)
    end

    def cache_key(description)
      Digest::SHA256.hexdigest("rails_db_analytics:#{description}:#{schema_content}")
    end
  end

  class << self
    attr_writer :configuration

    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end

    def register_report(report_class)
      @registered_reports ||= []
      @registered_reports << report_class
    end

    def registered_reports
      @registered_reports || []
    end
  end
end

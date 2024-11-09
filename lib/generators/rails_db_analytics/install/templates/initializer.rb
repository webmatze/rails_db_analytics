# frozen_string_literal: true

RailsDbAnalytics.configure do |config|
  # Configure the Anthropic API client
  config.anthropic_api_key = Rails.application.credentials.dig(:anthropic, :api_key)

  # Configure the LLM model to use (defaults to claude-3-sonnet-20240229)
  # config.llm_model = "claude-3-sonnet-20240229"

  # Configure the maximum number of tokens to generate (defaults to 4096)
  # config.max_tokens = 4096

  # Configure the temperature for LLM responses (defaults to 0.7)
  # config.temperature = 0.7

  # Configure the path to the schema.rb file (defaults to Rails.root.join('db/schema.rb'))
  # config.schema_path = Rails.root.join('db/schema.rb')

  # Configure the cache store for LLM responses (defaults to Rails.cache)
  # config.cache_store = Rails.cache

  # Configure whether to cache LLM responses (defaults to true in production)
  # config.cache_responses = Rails.env.production?

  # Configure the cache TTL for LLM responses (defaults to 1 hour)
  # config.cache_ttl = 1.hour
end

# frozen_string_literal: true

module RailsDbAnalytics
  class ReportGeneratorService
    SYSTEM_PROMPT = <<~PROMPT
      You are a Ruby on Rails expert. Generate a DataReport subclass based on the schema and description provided.
      The class should implement:

      1. report_data: Returns an ActiveRecord::Relation that fetches the required data
      2. format_data: Takes the query result and returns a hash with analyzed data

      Follow these guidelines:
      - Use only the models and relationships available in the schema
      - Write efficient queries using ActiveRecord methods
      - Include proper date range filtering using the @date_range instance variable
      - Format the data in a clear, structured way
      - Add comments explaining the analysis logic
      - Handle edge cases and potential nil values
      - Use proper Ruby/Rails conventions
    PROMPT

    def initialize(description)
      @description = description
    end

    def generate
      RailsDbAnalytics.with_caching(@description) do
        response = RailsDbAnalytics.anthropic_client.messages.create(
          model: RailsDbAnalytics.configuration.llm_model,
          max_tokens: RailsDbAnalytics.configuration.max_tokens,
          temperature: RailsDbAnalytics.configuration.temperature,
          system: SYSTEM_PROMPT,
          messages: [{
            role: "user",
            content: message_content
          }]
        )

        process_response(response.content)
      end
    end

    private

    def message_content
      <<~CONTENT
        Generate a DataReport subclass for the following description:
        #{@description}

        Using this schema:
        #{RailsDbAnalytics.schema_content}

        The class should inherit from RailsDbAnalytics::DataReport and implement both report_data and format_data methods.
        Return ONLY the Ruby code for the class, without any explanation or markdown formatting.
      CONTENT
    end

    def process_response(content)
      # Clean up the response to ensure it's valid Ruby code
      content = content.strip
      content = content.gsub(/```ruby\n?/, '').gsub(/```\n?/, '')

      # Ensure the class inherits from our base class
      unless content.include?("< RailsDbAnalytics::DataReport")
        raise Error, "Generated code does not inherit from RailsDbAnalytics::DataReport"
      end

      # Ensure required methods are defined
      unless content.include?("def report_data") && content.include?("def format_data")
        raise Error, "Generated code is missing required methods"
      end

      content
    end
  end
end

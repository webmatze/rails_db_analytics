# frozen_string_literal: true

module RailsDbAnalytics
  class SavedReportsController < ApplicationController
    def index
      @saved_reports = SavedReport.order(created_at: :desc)
    end

    def show
      @saved_report = SavedReport.find(params[:id])
    end

    def new
      @saved_report = SavedReport.new
    end

    def create
      @saved_report = SavedReport.new(saved_report_params)

      if @saved_report.save
        @saved_report.refresh_data!
        redirect_to @saved_report, notice: 'Report was successfully created.'
      else
        render :new
      end
    end

    def generate
      schema = Rails.root.join('db/schema.rb').read
      description = params[:description]

      if description.blank?
        flash[:error] = 'Description cannot be blank'
        redirect_to new_saved_report_path and return
      end

      begin
        # Generate report class using LLM
        message = anthropic_client.messages(
          parameters: {
            model: "claude-3-sonnet-20240229",
            max_tokens: 4096,
            temperature: 0.7,
            system: "You are a Ruby on Rails expert. Generate a DataReport subclass based on the schema and description provided. The class should implement report_data to return an ActiveRecord::Relation and format_data to return a hash of the analyzed data.",
            messages: [{
              role: "user",
              content: "Generate a DataReport subclass for the following description: #{description}\n\nSchema:\n#{schema}"
            }]
          }
        )

        report_class_name = "RailsDbAnalytics::GeneratedReport#{Time.current.to_i}"
        report_class_content = message["content"][0]["text"]

        # Extract code block with error handling
        code_block_match = report_class_content.match(/```ruby\n(.*?)\n```/m)
        raise "Invalid response format from LLM" unless code_block_match
        code_block = code_block_match[1]

        # Create the report class
        Object.const_set(report_class_name, Class.new(DataReport) do
          class_eval(code_block)
        end)

        # Create and save the report
        @saved_report = SavedReport.create!(
          name: description.truncate(50),
          description: description,
          report_class: report_class_name
        )
        @saved_report.refresh_data!

        redirect_to @saved_report, notice: 'Report was successfully generated.'

      rescue Anthropic::Error => e
        Rails.logger.error("Anthropic API error: #{e.message}")
        flash[:error] = 'Failed to generate report due to AI service error. Please try again later.'
        redirect_to saved_reports_path
      rescue StandardError => e
        Rails.logger.error("Report generation error: #{e.message}")
        flash[:error] = 'An error occurred while generating the report. Please try again.'
        redirect_to saved_reports_path
      end
    end

    def refresh
      @saved_report = SavedReport.find(params[:id])
      @saved_report.refresh_data!
      redirect_to @saved_report, notice: 'Report data was successfully refreshed.'
    end

    private

    def saved_report_params
      params.require(:saved_report).permit(:name, :description)
    end
  end
end

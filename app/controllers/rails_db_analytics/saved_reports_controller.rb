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

      # Generate report class using LLM
      client = Anthropic::Client.new
      message = client.messages.create(
        model: "claude-3-sonnet-20240229",
        max_tokens: 4096,
        temperature: 0.7,
        system: "You are a Ruby on Rails expert. Generate a DataReport subclass based on the schema and description provided. The class should implement report_data to return an ActiveRecord::Relation and format_data to return a hash of the analyzed data.",
        messages: [{
          role: "user",
          content: "Generate a DataReport subclass for the following description: #{description}\n\nSchema:\n#{schema}"
        }]
      )

      report_class_name = "RailsDbAnalytics::GeneratedReport#{Time.current.to_i}"
      report_class_content = message.content

      # Create the report class
      Object.const_set(report_class_name, Class.new(DataReport) do
        class_eval(report_class_content)
      end)

      # Create and save the report
      @saved_report = SavedReport.create!(
        name: description.truncate(50),
        description: description,
        report_class: report_class_name
      )
      @saved_report.refresh_data!

      redirect_to @saved_report, notice: 'Report was successfully generated.'
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

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
        redirect_to @saved_report, notice: "Report was successfully created."
      else
        render :new
      end
    end

    def generate
      schema = Rails.root.join("db/schema.rb").read
      description = params[:description]

      if description.blank?
        flash[:error] = "Description cannot be blank"
        redirect_to new_saved_report_path and return
      end

      begin
        # Generate report class using LLM
        message = anthropic_client.messages(
          parameters: {
            model: "claude-3-sonnet-20240229",
            max_tokens: 4096,
            temperature: 0.7,
            system: system_prompt,
            messages: [{
              role: "user",
              content: "Generate a RailsDbAnalytics::DataReport subclass for the following description: #{description}\n\nRailsDbAnalytics::DataReport source code:\n#{data_report_class_source}\n\nSchema:\n#{schema}"
            }]
          }
        )

        # report_class_name = "RailsDbAnalytics::GeneratedReport#{Time.current.strftime('%Y%m%d%H%M%S')}"
        report_class_content = message["content"][0]["text"]

        # Extract code block with error handling
        code_block_match = report_class_content.match(/```ruby\n(.*?)\n```/m)
        raise "Invalid response format from LLM" unless code_block_match

        code_block = code_block_match[1]
        Rails.logger.debug("Generated report class code:\n#{code_block}")

        # Create the report class with a valid constant name
        # TODO: This is unsafe, we should use a sandboxed environment
        eval(code_block)  # Just evaluate the code to define the class
        report_class_name = code_block.match(/class\s+([^\s<]+)/)[1]  # Extract class name from code
        Rails.logger.debug("Report class name: #{report_class_name}")

        # Create and save the report
        @saved_report = SavedReport.create!(
          name: description.truncate(50),
          description: description,
          report_class_name: report_class_name,
          report_class: code_block
        )
        Rails.logger.debug("Saved report: #{@saved_report.inspect}")
        @saved_report.refresh_data!

        redirect_to @saved_report, notice: "Report was successfully generated."
      rescue Anthropic::Error => e
        Rails.logger.error("Anthropic API error: #{e.message}")
        flash[:error] = "Failed to generate report due to AI service error. Please try again later."
        redirect_to saved_reports_path
      rescue StandardError => e
        Rails.logger.error("Report generation error: #{e.message}")
        flash[:error] = "An error occurred while generating the report. Please try again."
        redirect_to saved_reports_path
      end
    end

    def refresh
      @saved_report = SavedReport.find(params[:id])
      @saved_report.refresh_data!
      redirect_to @saved_report, notice: "Report data was successfully refreshed."
    end

    def destroy
      @saved_report = SavedReport.find(params[:id])
      @saved_report.destroy

      redirect_to saved_reports_path, notice: 'Report was successfully deleted.'
    rescue ActiveRecord::RecordNotFound
      redirect_to saved_reports_path, alert: 'Report not found.'
    end

    private

    def data_report_class_source
      # Get the source location of the class
      source_location = RailsDbAnalytics::DataReport.instance_method(:initialize).source_location

      # Read the file and extract the class definition
      if source_location
        file_path = source_location[0]
        line_number = source_location[1]

        # Read the file and display the relevant lines
        source_code = File.readlines(file_path)[line_number - 5..line_number + 20].join
        Rails.logger.debug("Source code for RailsDbAnalytics::DataReport:\n#{source_code}")
        source_code
      else
        Rails.logger.error("Source location not found.")
        nil
      end
    end

    def saved_report_params
      params.require(:saved_report).permit(:name, :description)
    end

    def system_prompt
      @system_prompt ||= begin
        system_prompt_file = Engine.root.join("config/rails_db_analytics/prompts/data_report_generator.txt")
        raise "System prompt file not found: #{system_prompt_file}" unless system_prompt_file.exist?

        prompt = File.read(system_prompt_file.to_s)
        prompt.gsub!("{{database_name}}", ActiveRecord::Base.connection.adapter_name.downcase + ' ' + ActiveRecord::Base.connection.database_version.to_s)
        prompt
      end
    end
  end
end

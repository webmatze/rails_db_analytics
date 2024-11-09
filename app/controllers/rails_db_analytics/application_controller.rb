# frozen_string_literal: true

module RailsDbAnalytics
  class ApplicationController < ActionController::Base
    protect_from_forgery with: :exception

    layout 'rails_db_analytics/application'

    private

    def anthropic_client
      @anthropic_client ||= Anthropic::Client.new(
        api_key: Rails.application.credentials.anthropic_api_key
      )
    end
  end
end

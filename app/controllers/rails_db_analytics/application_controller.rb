# frozen_string_literal: true

module RailsDbAnalytics
  class ApplicationController < ActionController::Base
    protect_from_forgery with: :exception

    layout "rails_db_analytics/application"

    private

    def anthropic_client
      RailsDbAnalytics.configuration.anthropic_client
    end
  end
end

# frozen_string_literal: true

require "rails"
require "anthropic"
require "view_component"
require "importmap-rails"
require "tailwindcss-rails"
require "stimulus-rails"

require_relative "rails_db_analytics/version"
require_relative "rails_db_analytics/configuration"
require_relative "rails_db_analytics/engine"

module RailsDbAnalytics
end

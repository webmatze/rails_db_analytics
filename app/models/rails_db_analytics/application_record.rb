# frozen_string_literal: true

module RailsDbAnalytics
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true
  end
end

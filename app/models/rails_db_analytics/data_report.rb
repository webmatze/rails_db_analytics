# frozen_string_literal: true

module RailsDbAnalytics
  class DataReport
    attr_reader :date_range

    def initialize(date_range: 1.day.ago..Time.zone.now)
      @date_range = date_range
    end

    def self.inherited(subclass)
      super
      RailsDbAnalytics.register_report(subclass)
    end

    # This method should be overridden by subclasses to execute the ActiveRecord query
    def report_data
      raise NotImplementedError, "#{self.class} must implement #report_data"
    end

    # This method should be overridden by subclasses to format the data
    def format_data(data)
      raise NotImplementedError, "#{self.class} must implement #format_data"
    end

    def execute
      data = report_data
      format_data(data)
    end
  end
end

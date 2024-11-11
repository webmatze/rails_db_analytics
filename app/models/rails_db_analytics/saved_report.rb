# frozen_string_literal: true

module RailsDbAnalytics
  class SavedReport < ApplicationRecord
    validates :name, presence: true
    validates :description, presence: true
    validates :report_class, presence: true
    validates :report_class_name, presence: true

    def report_instance
      eval(report_class)
      report_class_name.constantize.new
    end

    def refresh_data!
      update!(
        report_data: report_instance.execute,
        last_run_at: Time.current
      )
    end
  end
end

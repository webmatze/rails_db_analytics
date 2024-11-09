# frozen_string_literal: true

module RailsDbAnalytics
  class SavedReport < ApplicationRecord
    validates :name, presence: true
    validates :description, presence: true
    validates :report_class, presence: true

    def report_instance
      report_class.constantize.new
    end

    def refresh_data!
      update!(
        report_data: report_instance.execute,
        last_run_at: Time.current
      )
    end
  end
end

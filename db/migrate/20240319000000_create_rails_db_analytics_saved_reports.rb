# frozen_string_literal: true

class CreateRailsDbAnalyticsSavedReports < ActiveRecord::Migration[7.0]
  def change
    create_table :rails_db_analytics_saved_reports do |t|
      t.string :name, null: false
      t.text :description, null: false
      t.string :report_class, null: false
      t.json :report_data
      t.datetime :last_run_at
      t.timestamps
    end

    add_index :rails_db_analytics_saved_reports, :name
    add_index :rails_db_analytics_saved_reports, :report_class
  end
end

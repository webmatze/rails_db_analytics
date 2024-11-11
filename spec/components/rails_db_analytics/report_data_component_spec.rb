# frozen_string_literal: true

require "spec_helper"
require "active_record"
require_relative "../../../app/models/rails_db_analytics/application_record"
require_relative "../../../app/models/rails_db_analytics/saved_report"
require_relative "../../../app/components/rails_db_analytics/report_data_component"

RSpec.describe RailsDbAnalytics::ReportDataComponent, type: :component do
  let(:report) do
    instance_double(
      RailsDbAnalytics::SavedReport,
      report_data: report_data,
      last_run_at: Time.current
    )
  end

  describe "#render" do
    context "with numeric data" do
      let(:report_data) do
        {
          total_count: 100,
          average_value: 42.5
        }
      end

      it "renders numeric values" do
        render_inline(described_class.new(report: report))

        expect(page).to have_text("100")
        expect(page).to have_text("42.5")
      end

      it "renders a chart for numeric data" do
        render_inline(described_class.new(report: report))

        expect(page).to have_css("[data-controller='chart']")
        expect(page).to have_css("canvas[data-chart-target='canvas']")
      end
    end

    context "with hash data" do
      let(:report_data) do
        {
          breakdown: {
            category_a: 40,
            category_b: 60
          }
        }
      end

      it "renders hash keys and values" do
        render_inline(described_class.new(report: report))

        expect(page).to have_text("Category A")
        expect(page).to have_text("40")
        expect(page).to have_text("Category B")
        expect(page).to have_text("60")
      end
    end

    context "with array data" do
      let(:report_data) do
        {
          top_items: [
            { name: "Item 1", count: 10 },
            { name: "Item 2", count: 8 }
          ]
        }
      end

      it "renders array items" do
        render_inline(described_class.new(report: report))

        expect(page).to have_text("Item 1")
        expect(page).to have_text("10")
        expect(page).to have_text("Item 2")
        expect(page).to have_text("8")
      end
    end

    context "with no data" do
      let(:report_data) { nil }

      it "renders empty state message" do
        render_inline(described_class.new(report: report))

        expect(page).to have_text("No data available")
        expect(page).to have_button("Refresh Data")
      end
    end

    context "with last_run_at timestamp" do
      let(:report_data) { { count: 42 } }
      let(:last_run_at) { 1.hour.ago }

      before do
        allow(report).to receive(:last_run_at).and_return(last_run_at)
      end

      it "renders last updated timestamp" do
        render_inline(described_class.new(report: report))

        expect(page).to have_text("Last updated: about 1 hour ago")
      end
    end
  end

  describe "chart data handling" do
    context "with chartable data" do
      let(:report_data) do
        {
          monthly_stats: {
            January: 100,
            February: 150,
            March: 200
          }
        }
      end

      it "prepares data for Chart.js" do
        render_inline(described_class.new(report: report))

        canvas = page.find("canvas[data-chart-target='canvas']")
        chart_data = JSON.parse(canvas["data-chart-data"])

        expect(chart_data["labels"]).to eq(%w[January February March])
        expect(chart_data["datasets"].first["data"]).to eq([100, 150, 200])
      end
    end

    context "with non-chartable data" do
      let(:report_data) do
        {
          summary: "Just a text summary"
        }
      end

      it "does not render chart" do
        render_inline(described_class.new(report: report))

        expect(page).to have_no_css("[data-controller='chart']")
      end
    end
  end
end

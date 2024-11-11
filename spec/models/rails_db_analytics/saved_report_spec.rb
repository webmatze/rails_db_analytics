# frozen_string_literal: true

require "spec_helper"

RSpec.describe RailsDbAnalytics::SavedReport do
  let(:report_class_name) { "TestReport" }
  let(:report_instance) { instance_double(report_class_name, execute: report_data) }
  let(:report_data) do
    {
      total_count: 100,
      breakdown: {
        category_a: 40,
        category_b: 60
      }
    }
  end

  before do
    stub_const(report_class_name, Class.new(RailsDbAnalytics::DataReport))
    allow(report_class_name.constantize).to receive(:new).and_return(report_instance)
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:description) }
    it { is_expected.to validate_presence_of(:report_class) }
  end

  describe "#report_instance" do
    let(:saved_report) do
      described_class.new(
        name: "Test Report",
        description: "A test report",
        report_class: report_class_name
      )
    end

    it "instantiates the report class" do
      saved_report.report_instance
      expect(report_class_name.constantize).to have_received(:new)
    end

    context "when report class doesn't exist" do
      let(:report_class_name) { "NonExistentReport" }

      it "raises NameError" do
        expect { saved_report.report_instance }.to raise_error(NameError)
      end
    end
  end

  describe "#refresh_data!" do
    let(:saved_report) do
      described_class.create!(
        name: "Test Report",
        description: "A test report",
        report_class: report_class_name
      )
    end

    it "updates report_data with executed results" do
      saved_report.refresh_data!
      expect(saved_report.reload.report_data).to eq(report_data)
    end

    it "updates last_run_at timestamp" do
      expect { saved_report.refresh_data! }
        .to change { saved_report.reload.last_run_at }
        .from(nil)
    end

    context "when execution fails" do
      before do
        allow(report_instance).to receive(:execute).and_raise(StandardError, "Test error")
      end

      it "raises the error" do
        expect { saved_report.refresh_data! }.to raise_error(StandardError, "Test error")
      end

      it "doesn't update the report data" do
        saved_report.update!(report_data: { old: "data" })
        expect do
          saved_report.refresh_data!
        rescue StandardError
          nil
        end
          .not_to(change { saved_report.reload.report_data })
      end
    end
  end

  describe "serialization" do
    let(:saved_report) do
      described_class.create!(
        name: "Test Report",
        description: "A test report",
        report_class: report_class_name,
        report_data: report_data
      )
    end

    it "serializes report_data as JSON" do
      reloaded_report = described_class.find(saved_report.id)
      expect(reloaded_report.report_data).to eq(report_data)
    end

    it "handles nested data structures" do
      expect(saved_report.report_data["breakdown"]).to eq(
        "category_a" => 40,
        "category_b" => 60
      )
    end
  end
end

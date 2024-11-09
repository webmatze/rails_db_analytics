# frozen_string_literal: true

require "spec_helper"

RSpec.describe RailsDbAnalytics::SavedReportsController, type: :controller do
  # routes { RailsDbAnalytics::Engine.routes }

  let(:report_generator) { instance_double(RailsDbAnalytics::ReportGeneratorService) }
  let(:generated_report_code) do
    <<~RUBY
      class GeneratedReport123 < RailsDbAnalytics::DataReport
        def report_data
          User.joins(:posts).group('users.id').count
        end

        def format_data(data)
          { user_posts: data }
        end
      end
    RUBY
  end

  before do
    allow(RailsDbAnalytics::ReportGeneratorService).to receive(:new).and_return(report_generator)
    allow(report_generator).to receive(:generate).and_return(generated_report_code)
  end

  describe "GET #index" do
    let!(:reports) { create_list(:saved_report, 3) }

    it "returns a successful response" do
      get :index
      expect(response).to be_successful
    end

    it "assigns @saved_reports" do
      get :index
      expect(assigns(:saved_reports)).to match_array(reports)
    end
  end

  describe "GET #show" do
    let(:report) { create(:saved_report) }

    it "returns a successful response" do
      get :show, params: { id: report.id }
      expect(response).to be_successful
    end

    it "assigns @saved_report" do
      get :show, params: { id: report.id }
      expect(assigns(:saved_report)).to eq(report)
    end
  end

  describe "POST #generate" do
    let(:description) { "Show me user signup trends over the last month" }
    let(:valid_params) { { description: description } }

    context "with valid parameters" do
      it "creates a new report" do
        expect {
          post :generate, params: valid_params
        }.to change(RailsDbAnalytics::SavedReport, :count).by(1)
      end

      it "generates report class using LLM" do
        post :generate, params: valid_params
        expect(RailsDbAnalytics::ReportGeneratorService)
          .to have_received(:new)
          .with(description)
      end

      it "sets the report name from description" do
        post :generate, params: valid_params
        expect(RailsDbAnalytics::SavedReport.last.name).to include("user signup trends")
      end

      it "redirects to the new report" do
        post :generate, params: valid_params
        expect(response).to redirect_to(saved_report_path(RailsDbAnalytics::SavedReport.last))
      end

      it "sets a success notice" do
        post :generate, params: valid_params
        expect(flash[:notice]).to eq("Report was successfully generated.")
      end
    end

    context "with invalid parameters" do
      let(:invalid_params) { { description: "" } }

      it "does not create a new report" do
        expect {
          post :generate, params: invalid_params
        }.not_to change(RailsDbAnalytics::SavedReport, :count)
      end

      it "redirects back with error" do
        post :generate, params: invalid_params
        expect(response).to redirect_to(saved_reports_path)
        expect(flash[:alert]).to be_present
      end
    end
  end

  describe "POST #refresh" do
    let(:report) { create(:saved_report) }

    it "refreshes the report data" do
      expect {
        post :refresh, params: { id: report.id }
      }.to change { report.reload.last_run_at }
    end

    it "redirects to the report" do
      post :refresh, params: { id: report.id }
      expect(response).to redirect_to(saved_report_path(report))
    end

    it "sets a success notice" do
      post :refresh, params: { id: report.id }
      expect(flash[:notice]).to eq("Report data was successfully refreshed.")
    end

    context "when refresh fails" do
      before do
        allow_any_instance_of(RailsDbAnalytics::SavedReport)
          .to receive(:refresh_data!)
          .and_raise(StandardError, "Refresh failed")
      end

      it "redirects with error" do
        post :refresh, params: { id: report.id }
        expect(response).to redirect_to(saved_report_path(report))
        expect(flash[:alert]).to include("Refresh failed")
      end
    end
  end
end

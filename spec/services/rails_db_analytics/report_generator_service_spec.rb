# frozen_string_literal: true

require "spec_helper"

RSpec.describe RailsDbAnalytics::ReportGeneratorService do
  let(:schema_content) do
    <<~SCHEMA
      ActiveRecord::Schema[7.0].define(version: 2024_03_19_000000) do
        create_table "users", force: :cascade do |t|
          t.string "name"
          t.string "email"
          t.datetime "created_at", null: false
          t.datetime "updated_at", null: false
        end

        create_table "posts", force: :cascade do |t|
          t.bigint "user_id", null: false
          t.string "title"
          t.text "content"
          t.datetime "created_at", null: false
          t.datetime "updated_at", null: false
          t.index ["user_id"], name: "index_posts_on_user_id"
        end
      end
    SCHEMA
  end

  let(:description) { "Show me the top 5 users with the most posts in the last month" }

  let(:expected_report_class) do
    <<~RUBY
      class UserPostsReport < RailsDbAnalytics::DataReport
        def report_data
          User.joins(:posts)
              .where(posts: { created_at: date_range })
              .group('users.id')
              .select('users.*, COUNT(posts.id) as posts_count')
              .order('posts_count DESC')
              .limit(5)
        end

        def format_data(data)
          {
            total_users: data.length,
            users: data.map do |user|
              {
                name: user.name,
                email: user.email,
                posts_count: user.posts_count
              }
            end
          }
        end
      end
    RUBY
  end

  before do
    allow(RailsDbAnalytics).to receive(:schema_content).and_return(schema_content)

    allow(RailsDbAnalytics.configuration).to receive(:anthropic_client).and_return(
      instance_double(Anthropic::Client,
        messages: instance_double('Messages',
          create: instance_double('Response', content: expected_report_class)
        )
      )
    )
  end

  describe "#generate" do
    it "generates a valid report class", :vcr do
      service = described_class.new(description)
      result = service.generate

      expect(result).to include("< RailsDbAnalytics::DataReport")
      expect(result).to include("def report_data")
      expect(result).to include("def format_data")
    end

    it "includes proper ActiveRecord query methods", :vcr do
      service = described_class.new(description)
      result = service.generate

      expect(result).to include("joins")
      expect(result).to include("where")
      expect(result).to include("group")
      expect(result).to include("select")
    end

    it "handles date range filtering", :vcr do
      service = described_class.new(description)
      result = service.generate

      expect(result).to include("date_range")
    end

    context "when caching is enabled" do
      before do
        allow(RailsDbAnalytics.configuration).to receive(:cache_responses).and_return(true)
        allow(RailsDbAnalytics.configuration.cache_store).to receive(:fetch).and_yield
      end

      it "uses the cache", :vcr do
        service = described_class.new(description)
        service.generate

        expect(RailsDbAnalytics.configuration.cache_store).to have_received(:fetch)
      end
    end

    context "when the generated code is invalid" do
      let(:invalid_response) { "invalid ruby code" }

      before do
        allow(RailsDbAnalytics.configuration.anthropic_client.messages)
          .to receive(:create)
          .and_return(instance_double('Response', content: invalid_response))
      end

      it "raises an error", :vcr do
        service = described_class.new(description)

        expect { service.generate }.to raise_error(RailsDbAnalytics::Error)
      end
    end
  end
end

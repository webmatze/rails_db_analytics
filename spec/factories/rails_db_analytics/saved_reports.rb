# frozen_string_literal: true

FactoryBot.define do
  factory :saved_report, class: "RailsDbAnalytics::SavedReport" do
    sequence(:name) { |n| "Report #{n}" }
    sequence(:description) { |n| "Description for report #{n}" }
    report_class { "TestReport#{rand(1000)}" }
    report_data do
      {
        total_count: rand(100),
        breakdown: {
          category_a: rand(50),
          category_b: rand(50)
        },
        trend: [
          { date: 1.week.ago.to_date.to_s, value: rand(100) },
          { date: 1.day.ago.to_date.to_s, value: rand(100) }
        ]
      }
    end
    last_run_at { Time.current }

    trait :without_data do
      report_data { nil }
      last_run_at { nil }
    end

    trait :with_numeric_data do
      report_data do
        {
          total: rand(1000),
          average: rand(100.0),
          minimum: rand(10),
          maximum: rand(500..1000)
        }
      end
    end

    trait :with_categorical_data do
      report_data do
        {
          categories: {
            "Category A" => rand(100),
            "Category B" => rand(100),
            "Category C" => rand(100)
          }
        }
      end
    end

    trait :with_time_series do
      report_data do
        dates = (1..7).map { |n| n.days.ago.to_date }
        {
          daily_metrics: dates.map do |date|
            {
              date: date.to_s,
              value: rand(100)
            }
          end
        }
      end
    end

    trait :stale do
      last_run_at { 1.week.ago }
    end

    trait :fresh do
      last_run_at { 5.minutes.ago }
    end

    trait :invalid do
      name { nil }
      description { nil }
    end

    # Factory for testing different report types
    factory :user_activity_report do
      name { "User Activity Report" }
      description { "Analysis of user engagement and activity patterns" }
      report_class { "UserActivityReport" }
      report_data do
        {
          active_users: rand(1000),
          average_session_duration: rand(1..120),
          top_features: [
            { name: "Feature A", usage_count: rand(500) },
            { name: "Feature B", usage_count: rand(500) },
            { name: "Feature C", usage_count: rand(500) }
          ]
        }
      end
    end

    factory :performance_report do
      name { "Performance Metrics Report" }
      description { "System performance and response time analysis" }
      report_class { "PerformanceReport" }
      report_data do
        {
          average_response_time: rand(10..1000),
          error_rate: rand(0.1..5.0),
          throughput: rand(1000..5000),
          peak_times: [
            { hour: "09:00", requests: rand(1000) },
            { hour: "14:00", requests: rand(1000) },
            { hour: "17:00", requests: rand(1000) }
          ]
        }
      end
    end
  end
end

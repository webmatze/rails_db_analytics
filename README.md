# Rails DB Analytics

Rails DB Analytics is a powerful Rails engine that provides database analytics functionality by leveraging Large Language Models (LLM) to generate and execute data analysis reports. It analyzes your application's schema and allows users to create reports using natural language descriptions.

## Features

- 📊 Generate data analysis reports using natural language descriptions
- 🤖 Powered by Claude 3 Sonnet for intelligent query generation
- 📈 Interactive dashboard for managing reports
- 🔄 Real-time data refresh capabilities
- 🎨 Modern UI with Tailwind CSS
- ⚡️ Hotwire/Stimulus for dynamic interactions
- 🔒 Safe query generation with ActiveRecord
- 📦 Easy installation and configuration

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rails_db_analytics'
```

And then execute:
```bash
bundle install
```

Run the installation generator:
```bash
bin/rails generate rails_db_analytics:install
```

## Configuration

Configure the engine in `config/initializers/rails_db_analytics.rb`:

```ruby
RailsDbAnalytics.configure do |config|
  config.anthropic_api_key = Rails.application.credentials.dig(:anthropic, :api_key)
  
  # Optional configurations
  config.llm_model = "claude-3-sonnet-20240229"
  config.max_tokens = 4096
  config.temperature = 0.7
  config.schema_path = Rails.root.join('db/schema.rb')
  config.cache_store = Rails.cache
  config.cache_responses = Rails.env.production?
  config.cache_ttl = 1.hour
end
```

## Usage

1. Visit `/analytics` in your Rails application
2. Click "New Report" to create a data analysis report
3. Provide a natural language description of the data you want to analyze
4. The engine will:
   - Read your schema.rb
   - Generate a DataReport subclass using Claude
   - Execute the report
   - Display the results

### Example Report Descriptions

```
"Show me the top 10 users who have created the most posts in the last month,
including their total posts and average post length"

"Analyze the order trends over the last quarter, showing total revenue by
product category and identifying the best-selling products"

"Generate a user engagement report showing daily active users, average session
duration, and most used features in the last week"
```

## How It Works

1. **Schema Analysis**: The engine reads your Rails application's schema.rb to understand the database structure, relationships, and available data.

2. **Report Generation**: When you create a new report:
   - Your description is sent to Claude along with the schema
   - Claude generates a DataReport subclass with appropriate ActiveRecord queries
   - The report is saved and can be re-run at any time

3. **Data Collection**: The generated report class:
   - Implements `report_data` to fetch data using ActiveRecord
   - Implements `format_data` to structure the results
   - Supports date ranges for temporal analysis

Example generated report class:

```ruby
class UserEngagementReport < RailsDbAnalytics::DataReport
  def report_data
    User.joins(:sessions)
        .where(sessions: { created_at: date_range })
        .group('users.id')
        .select(
          'users.*, ' \
          'COUNT(sessions.id) as session_count, ' \
          'AVG(sessions.duration) as avg_duration'
        )
  end

  def format_data(data)
    {
      total_active_users: data.count,
      average_sessions_per_user: data.average(:session_count).round(2),
      average_session_duration: data.average(:avg_duration).round(2),
      most_active_users: data.order('session_count DESC').limit(5)
                            .map { |u| { name: u.name, sessions: u.session_count } }
    }
  end
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/webmatze/rails_db_analytics. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](LICENSE.txt).

## Code of Conduct

Everyone interacting in the Rails DB Analytics project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](CODE_OF_CONDUCT.md).

# Rails DB Analytics Installation

The Rails DB Analytics engine has been successfully installed! Here are a few final steps to complete the setup:

1. Add your Anthropic API key to your credentials:
   ```bash
   EDITOR='code --wait' bin/rails credentials:edit
   ```
   Add the following:
   ```yaml
   anthropic:
     api_key: your_api_key_here
   ```

2. Run the migrations:
   ```bash
   bin/rails db:migrate
   ```

3. Mount the engine in your routes.rb (this should have been done automatically):
   ```ruby
   mount RailsDbAnalytics::Engine => '/analytics', as: 'rails_db_analytics'
   ```

4. Add the JavaScript and CSS imports to your application:

   In `app/javascript/application.js`:
   ```javascript
   import "rails_db_analytics"
   ```

   In `app/assets/stylesheets/application.tailwind.css`:
   ```css
   @import "rails_db_analytics/application";
   ```

5. Configure the engine in `config/initializers/rails_db_analytics.rb` if needed.

## Usage

1. Visit `/analytics` to access the analytics dashboard
2. Click "New Report" to create a new data analysis report
3. Describe what data you want to analyze in plain English
4. The engine will generate a report class using Claude to analyze your database

## Example Report Description

Here's an example of what you can ask for:

"Show me the top 10 most active users in the last month, including their total number of actions and their most common action type"

The engine will analyze your schema.rb, understand the relationships between your models, and generate appropriate ActiveRecord queries to fetch and analyze the data.

## Customization

You can customize the engine's behavior through the initializer file at `config/initializers/rails_db_analytics.rb`. Available options include:

- LLM model selection
- Token limits
- Temperature settings
- Schema path
- Caching configuration

## Need Help?

Check out the full documentation at:
https://github.com/webmatze/rails_db_analytics

For issues and feature requests, please visit:
https://github.com/webmatze/rails_db_analytics/issues

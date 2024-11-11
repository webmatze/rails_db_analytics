# frozen_string_literal: true

require_relative "lib/rails_db_analytics/version"

Gem::Specification.new do |spec|
  spec.name = "rails_db_analytics"
  spec.version = RailsDbAnalytics::VERSION
  spec.authors = ["Mathias Karstädt"]
  spec.email = ["mathias.karstaedt@gmail.com"]

  spec.summary = "Rails engine for database analytics using LLM"
  spec.description = "Provides database analytics functionality by analyzing schema.rb and generating reports using LLM technology"
  spec.homepage = "https://github.com/webmatze/rails_db_analytics"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/webmatze/rails_db_analytics"
  spec.metadata["changelog_uri"] = "https://github.com/webmatze/rails_db_analytics/blob/main/CHANGELOG.md"

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  # Core dependencies
  spec.add_dependency "rails", ">= 7.0.0"
  spec.add_dependency "anthropic", "~> 0.3"
  spec.add_dependency "view_component", "~> 3.0"

  # Asset dependencies
  spec.add_dependency "tailwindcss-rails", "~> 3.0"
  spec.add_dependency "stimulus-rails", "~> 1.3"
  spec.add_dependency "importmap-rails", "~> 1.2"
  spec.add_dependency "propshaft", "~> 1.1"

  # Development dependencies
  spec.add_development_dependency "rspec-rails", "~> 6.0"
  spec.add_development_dependency "factory_bot_rails", "~> 6.2"
  spec.add_development_dependency "sqlite3", "~> 1.4"
  spec.add_development_dependency "rubocop", "~> 1.50"
  spec.add_development_dependency "rubocop-rails", "~> 2.19"
  spec.add_development_dependency "rubocop-rspec", "~> 2.22"
  spec.add_development_dependency "rubocop-performance", "~> 1.18"
  spec.add_development_dependency "brakeman", "~> 6.0"
  spec.add_development_dependency "bundler-audit", "~> 0.9"
  spec.add_development_dependency "simplecov", "~> 0.22"
  spec.add_development_dependency "vcr", "~> 6.1"
  spec.add_development_dependency "webmock", "~> 3.18"
  spec.add_development_dependency "pry-byebug", "~> 3.10"
  spec.add_development_dependency "yard", "~> 0.9"
end

# frozen_string_literal: true

module RailsDbAnalytics
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path('templates', __dir__)

      def create_initializer
        template 'initializer.rb', 'config/initializers/rails_db_analytics.rb'
      end

      def mount_engine
        route "mount RailsDbAnalytics::Engine => '/analytics', as: 'rails_db_analytics'"
      end

      def copy_migrations
        rake 'rails_db_analytics:install:migrations'
      end

      def add_anthropic_credentials
        say "\nPlease add your Anthropic API key to your credentials file:"
        say "Run: EDITOR='code --wait' bin/rails credentials:edit"
        say "Add the following:"
        say "anthropic:"
        say "  api_key: your_api_key_here\n"
      end

      def create_tailwind_config
        @engines_paths = RailsDbAnalytics.configuration.tailwind_content

        template 'config/tailwind.config.js', 'config/tailwind.config.js'
      end

      def show_readme
        readme 'README.md'
      end
    end
  end
end

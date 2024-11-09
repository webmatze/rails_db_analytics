# frozen_string_literal: true

require "bundler/setup"

APP_RAKEFILE = File.expand_path("spec/dummy/Rakefile", __dir__)
load "rails/tasks/engine.rake"
load "rails/tasks/statistics.rake"

require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "rubocop/rake_task"
require "yard"

# RSpec tasks
RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = "spec/**/*_spec.rb"
  t.rspec_opts = "--color --format documentation"
end

# RuboCop tasks
RuboCop::RakeTask.new(:rubocop) do |t|
  t.options = ["--display-cop-names", "--autocorrect"]
  t.formatters = ["progress"]
  t.paths = ["lib", "app", "spec"]
end

# YARD documentation tasks
YARD::Rake::YardocTask.new do |t|
  t.files = ["lib/**/*.rb", "app/**/*.rb"]
  t.options = ["--output-dir", "doc", "--readme", "README.md"]
end

# Brakeman security scan
task :brakeman do
  require "brakeman"
  Brakeman.run(
    app_path: ".",
    output_formats: [:text],
    print_report: true
  )
end

# Bundler audit for dependency vulnerabilities
task :bundle_audit do
  require "bundler/audit/task"
  Bundler::Audit::Task.new
  Rake::Task["bundle:audit"].invoke
end

# Combined quality checks
task quality: [:rubocop, :spec, :brakeman, :bundle_audit]

# Default task
task default: :spec

# Release tasks
namespace :release do
  desc "Prepare for a new release"
  task :prepare do
    # Update version
    version = ENV["VERSION"]
    raise "Please specify VERSION=x.x.x" unless version

    # Update version file
    version_file = "lib/rails_db_analytics/version.rb"
    content = File.read(version_file)
    content.gsub!(/VERSION = ".*"/, %{VERSION = "#{version}"})
    File.write(version_file, content)

    # Update changelog
    changelog_file = "CHANGELOG.md"
    changelog = File.read(changelog_file)
    changelog = "## [#{version}] - #{Time.now.strftime("%Y-%m-%d")}\n\n" + changelog
    File.write(changelog_file, changelog)

    puts "Prepared release #{version}"
  end

  desc "Generate documentation"
  task docs: :yard do
    puts "Documentation generated in doc/"
  end
end

# frozen_string_literal: true

namespace :tailwindcss do
  desc "Generates your tailwind config file"
  task :config do
    Rails::Generators.invoke("tailwind_config", ["--force"])
  end
end

Rake::Task["tailwindcss:build"].enhance(["tailwindcss:config"])
Rake::Task["tailwindcss:watch"].enhance(["tailwindcss:config"])

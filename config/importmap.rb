pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true

pin "chart.js", to: "https://ga.jspm.io/npm:chart.js@4.4.6/dist/chart.js"
pin "@kurkle/color", to: "https://ga.jspm.io/npm:@kurkle/color@0.3.2/dist/color.esm.js"

pin "application", to: "rails_db_analytics/application.js", preload: true

# pin_all_from RailsDbAnalytics::Engine.root.join("app/assets/javascript")
pin_all_from RailsDbAnalytics::Engine.root.join("app/assets/javascript/rails_db_analytics/controllers"),
             under: "controllers", to: "rails_db_analytics/controllers"

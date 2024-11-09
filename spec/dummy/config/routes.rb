Rails.application.routes.draw do
  root 'home#index'
  mount RailsDbAnalytics::Engine => '/analytics', as: 'rails_db_analytics'
end

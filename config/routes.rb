# frozen_string_literal: true

RailsDbAnalytics::Engine.routes.draw do
  resources :saved_reports do
    member do
      post :refresh
    end
    collection do
      post :generate
    end
  end

  root to: 'saved_reports#index'
end

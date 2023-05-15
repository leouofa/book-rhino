Rails.application.routes.draw do
  require 'sidekiq/web'

  # mount Sidekiq::Web in your Rails app
  mount Sidekiq::Web => "/sidekiq"

  devise_for :users
  apipie

  root "page#index"
  resources :feeds, only: %i[index]
  resources :stories, only: %i[index show]
  resources :discussions, only: %i[index show]
  resources :tweets, only: %i[index]
  resources :imaginations, only: %i[index]
  resources :tags, only: %i[index]

  resources :unauthorized, only: %i[index]

  namespace :api, defaults: { format: 'json' } do
    namespace :v1 do
      resource :test, only: %i[index]
    end
  end

  namespace :webhooks do
    resources :midjourney
  end
end

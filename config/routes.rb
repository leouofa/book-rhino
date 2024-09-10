Rails.application.routes.draw do
  require 'sidekiq/web'

  authenticate :user, ->(u) { u.admin? } do
    mount Sidekiq::Web => '/sidekiq'
  end

  devise_for :users

  root "page#index"
  resources :writing_styles

  resources :unauthorized, only: %i[index]
  resources :settings, only: [:index, :edit]
  resource :settings, only: [:update]
end

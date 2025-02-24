Rails.application.routes.draw do
  resources :regions
  require 'sidekiq/web'

  # Admin access to Sidekiq
  authenticate :user, ->(u) { u.admin? } do
    mount Sidekiq::Web => '/sidekiq'
  end

  devise_for :users

  root "page#index"

  concern :versionable do
    resources :versions, only: %i[index] do
      member do
        post :revert
        post :merge
      end
    end
  end

  resources :writing_styles do
    resources :texts
    post :generate_prompt, :iterate, on: :member
    get :edit_prompt, on: :member

    scope module: :writing_style do
      concerns :versionable
    end
  end

  resources :books do
    post :generate_prompt, :iterate, :render_book, on: :member
    get :edit_prompt, :read, on: :member

    scope module: :book do
      concerns :versionable
    end
  end

  resources :characters do
    post :generate_prompt, :iterate, on: :member
    get :edit_prompt, on: :member

    scope module: :character do
      concerns :versionable
    end
  end

  resources :locations do
    post :generate_prompt, :iterate, on: :member
    get :edit_prompt, on: :member

    scope module: :location do
      concerns :versionable
    end
  end

  # Static resources
  resources :perspectives
  resources :archetypes
  resources :personality_traits
  resources :moral_alignments
  resources :narrative_structures
  resources :character_types

  # Other resources
  resources :unauthorized, only: %i[index]
  resources :settings, only: %i[index edit]
  resource :settings, only: %i[update]
end

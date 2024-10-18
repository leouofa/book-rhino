Rails.application.routes.draw do
  require 'sidekiq/web'

  authenticate :user, ->(u) { u.admin? } do
    mount Sidekiq::Web => '/sidekiq'
  end

  devise_for :users

  root "page#index"

  resources :writing_styles do
    resources :texts

    member do
      post :iterate
    end

    scope module: :writing_style do
      resources :versions do
        member do
          post :revert
          post :merge
        end
      end
    end
  end

  resources :books
  resources :characters do
    member do
      post :generate_prompt
      post :iterate
    end

    scope module: :character do
      resources :versions do
        member do
          post :revert
          post :merge
        end
      end
    end
  end

  resources :perspectives
  resources :archetypes
  resources :personality_traits
  resources :moral_alignments
  resources :narrative_structures
  resources :character_types

  resources :unauthorized, only: %i[index]
  resources :settings, only: [:index, :edit]
  resource :settings, only: [:update]
end

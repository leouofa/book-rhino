# frozen_string_literal: true

Rails.application.routes.draw do
  resources :regions
  require 'sidekiq/web'

  # Admin access to Sidekiq
  authenticate :user, ->(u) { u.admin? } do
    mount Sidekiq::Web => '/sidekiq'
  end

  devise_for :users

  root 'page#index'

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

    resources :chapters do
      get :edit_prompt, on: :member
      post :render_chapter, :generate_scenes, on: :member
      resources :scenes, only: [:show] do
        post :render_scene, on: :member
      end
    end

    scope module: :book do
      concerns :versionable
    end
  end

  resources :characters do
    post :generate_prompt, :iterate, on: :member
    get :edit_prompt, on: :member
    resources :images, controller: :character_images, only: %i[create update destroy]

    scope module: :character do
      concerns :versionable
    end
  end

  resources :locations do
    post :generate_prompt, :iterate, on: :member
    get :edit_prompt, on: :member
    resources :images, controller: :location_images, only: %i[create update destroy]

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
  resources :poetic_forms, only: %i[index]
  resources :cinematic_styles, only: %i[index]
  resources :character_types

  # Other resources
  resources :unauthorized, only: %i[index]
  resources :settings, only: %i[index edit]
  resource :settings, only: %i[update]
  resources :api_tokens, only: %i[index create destroy]

  # REST API v1
  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      get 'health', to: 'health#show'
      get 'openapi.json', to: 'openapi#show'
      get 'me', to: 'me#show'

      resources :api_tokens, only: %i[index create destroy]
      resources :operations, only: %i[index show]

      resources :books, except: %i[new edit] do
        get :manuscript, on: :member
        post :generate_prompt, on: :member
        post :iterate, on: :member
        post :render_book, on: :member
        get :versions, on: :member
        post 'versions/:version_id/revert', to: 'books#revert_version', as: :revert_version
        post 'versions/:version_id/merge', to: 'books#merge_version', as: :merge_version

        resources :chapters, shallow: true, except: %i[new edit] do
          post :render_chapter, on: :member
          post :generate_scenes, on: :member

          resources :scenes, shallow: true, except: %i[new edit] do
            post :render_scene, on: :member
          end
        end
      end
      resources :chapters, only: %i[index create]
      resources :scenes, only: %i[index create]

      resources :characters, except: %i[new edit] do
        post :generate_prompt, on: :member
        post :iterate, on: :member
        get :versions, on: :member
        post 'versions/:version_id/revert', to: 'characters#revert_version', as: :revert_version
        post 'versions/:version_id/merge', to: 'characters#merge_version', as: :merge_version

        resources :images, controller: :character_images, shallow: true, except: %i[new edit]
      end
      resources :character_images, only: %i[show update destroy]

      resources :locations, except: %i[new edit] do
        post :generate_prompt, on: :member
        post :iterate, on: :member
        get :versions, on: :member
        post 'versions/:version_id/revert', to: 'locations#revert_version', as: :revert_version
        post 'versions/:version_id/merge', to: 'locations#merge_version', as: :merge_version

        resources :images, controller: :location_images, shallow: true, except: %i[new edit]
      end
      resources :location_images, only: %i[show update destroy]

      resources :regions, except: %i[new edit]

      resources :writing_styles, except: %i[new edit] do
        post :generate_prompt, on: :member
        post :iterate, on: :member
        get :versions, on: :member
        post 'versions/:version_id/revert', to: 'writing_styles#revert_version', as: :revert_version
        post 'versions/:version_id/merge', to: 'writing_styles#merge_version', as: :merge_version

        resources :texts, shallow: true, except: %i[new edit]
      end
      resources :texts, only: %i[index create]

      resources :perspectives, except: %i[new edit]
      resources :archetypes, except: %i[new edit]
      resources :personality_traits, except: %i[new edit]
      resources :moral_alignments, except: %i[new edit]
      resources :narrative_structures, except: %i[new edit]
      resources :character_types, except: %i[new edit]
      resources :poetic_forms, except: %i[new edit]
      resources :cinematic_styles, except: %i[new edit]

      resource :settings, only: %i[show update]
    end
  end
end

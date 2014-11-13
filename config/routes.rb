require 'sidekiq/api'

Rails.application.routes.draw do
  # mount Sidekiq::Web => '/current_tasks'

  resources :locations

  # resources :search, only: [:run] 
  # # do
    get '/search', to: 'search#run'
  # end

  

  resources :businesses, only: [ :index, :show, :delete ]

  root 'businesses#index'
end

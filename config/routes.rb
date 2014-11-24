require 'sidekiq/api'

Rails.application.routes.draw do
  # mount Sidekiq::Web => '/current_tasks'


  get '/search', to: 'search#run'


  

  resources :businesses, only: [ :index ] do 
    get :get_markers, on: :collection
    get :by_zipcode, on: :collection
  end

  root 'businesses#index'
end

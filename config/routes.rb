
require 'sidekiq/web'

Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  get '/health' => 'pages#health_check'
  get 'api-docs/v1/swagger.yaml' => 'swagger#yaml'
  # ... other routes ...

  namespace :api do
    resources :todos, only: [] do
      post 'categories', to: 'todos#associate_categories', on: :member
      post 'tags', to: 'todos#associate_tags', on: :member
      post '/', to: 'todos#create'
    end
  end

  # ... other routes ...
end

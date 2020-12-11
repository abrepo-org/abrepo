Rails.application.routes.draw do
  get 'test_models/test'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get 'healthcheck', action: :index, controller: 'healthcheck'

  post 'imports/test', action: :test, controller: 'imports'
  post 'imports', action: :create, controller: 'imports'
end

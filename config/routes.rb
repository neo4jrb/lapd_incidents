Rails.application.routes.draw do
  root 'dashboard#index'

  resources :incidents
end

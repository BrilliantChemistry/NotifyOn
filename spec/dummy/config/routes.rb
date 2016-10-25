Rails.application.routes.draw do

  devise_for :users

  resources :users do
    resources :messages
  end

  resources :messages
  resources :posts

  root :to => 'application#home'

end

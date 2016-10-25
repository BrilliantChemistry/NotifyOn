Rails.application.routes.draw do

  devise_for :users

  resources :users do
    resources :messages
  end

  resources :messages

  root :to => 'application#home'

end

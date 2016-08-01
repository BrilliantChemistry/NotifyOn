Rails.application.routes.draw do

  devise_for :users

  mount NotifyOn::Engine => '/notifications'

  resources :messages

  root :to => 'application#home'

end

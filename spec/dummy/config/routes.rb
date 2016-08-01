Rails.application.routes.draw do

  devise_for :users

  mount NotifyOn::Engine => '/notifications'

  root :to => 'application#home'

end

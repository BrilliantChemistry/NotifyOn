Rails.application.routes.draw do

  devise_for :users

  mount NotifyOn::Engine => "/notify_on"

end

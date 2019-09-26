Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'portal#index'
  get 'login', to: 'sessions#new'


  get 'scan', to: 'scans#new'
  post 'scan', to: 'scans#create'
  get 'show', to: 'scans#show'

end

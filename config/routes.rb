Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'portal#index'

  get 'login', to: 'sessions#new'
  post 'login', to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy'

  get 'scan', to: 'scans#new'
  post 'scan', to: 'scans#create'
  get 'show', to: 'scans#show'

  get 'labelcheck_search', to: 'labelchecks#search_deliveries'
  get 'search_deliveries', to: 'customers#search'
  get 'choose_deliveries', to: 'customers#choose'
  get 'labelcheck_check',  to: 'labelchecks#check_deliveries'
  get 'check_labels',      to: 'labelchecks#check_labels'
  get 'delivery_checked',  to: 'labelchecks#checked_delivery'

  #get 'labelcheck', to: 'labelchecks#check'
  #post 'labelcheck', to: 'labelcheck#create'
  #get 'show', to: 'labelchecks#show'

  #get 'deliverynote'

end

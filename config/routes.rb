Rails.application.routes.draw do
  
  #homepage
  root 'portal#index'

  #session
  get 'login', to: 'sessions#new'
  post 'login', to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy'

  #user
  get 'signup', to: 'kom_users#new'
  resources :kom_users, except: [:new]


  get 'labelcheck_search', to: 'labelchecks#search_deliveries'
  get 'search_deliveries', to: 'customers#search'
  get 'choose_deliveries_old', to: 'customers#choose'
  get 'labelcheck_check',  to: 'labelchecks#check_delivery'
  get 'check_labels_old',      to: 'labelchecks#check_labels'
  get 'delivery_checked',  to: 'labelchecks#checked_delivery'

  get 'beerkezes_gyartasbol_step1', to: 'beerkezes#step1'
  get 'search_production_orders_old', to: 'beerkezes#search_production_orders'
  get 'beerkezes_gyartasbol_step2', to: 'beerkezes#step2'
  get 'beerkezes_gyartasbol_step3', to: 'beerkezes#step3'
  get 'beerkezes_summary', to: 'beerkezes#summary'
  get 'beerkezes_gyartasbol_step4', to: 'beerkezes#step4'



  get 'receipt_from_production_index', to: 'receipts#receipt_from_production_index' 
  get 'search_production_orders', to: 'receipts#search_production_orders'
  get 'select_production_order', to: 'receipts#select_production_order'
  get 'get_storage_id', to: 'receipts#get_storage_id'
  get 'set_storage_id', to: 'receipts#set_storage_id'
  get 'save_record_path', to: 'receipts#save_record'

  get 'check_vda_index', to: 'vdachecks#check_vda_index'
  get 'check_internal_label', to: 'vdachecks#check_internal_label'
  get 'check_vda_label', to: 'vdachecks#check_vda_label'

  get 'check_delivery_index', to: 'deliverychecks#check_delivery_index'  
  get 'choose_customer_group', to: 'deliverychecks#choose_customer_group'
  get 'choose_deliveries', to: 'deliverychecks#choose_deliveries'
  get 'check_labels', to: 'deliverychecks#check_labels'

  get 'rfid_conversation_index', to: 'rfidconversations#rfid_conversation_index'
  get 'get_delivery_note', to: 'rfidconversations#get_delivery_note'

  get 'new_foam_request_index', to: 'foamrequests#new_foam_request_index'
  get 'set_parameters', to: 'foamrequests#set_parameters'
  get 'select_quantities', to: 'foamrequests#select_quantities'
  get 'set_quantities', to: 'foamrequests#set_quantities'

end

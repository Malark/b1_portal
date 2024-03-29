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


  #old, not used routes

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


  #living routes

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

  resources :foamrequests, :only => [:index, :edit, :update ]
  get 'delete_request', to: 'foamrequests#delete_request'
  get 'new_foam_request_index', to: 'foamrequests#new_foam_request_index'
  get 'set_parameters', to: 'foamrequests#set_parameters'
  get 'select_quantities', to: 'foamrequests#select_quantities'
  get 'set_quantities', to: 'foamrequests#set_quantities'
  get 'approve_request', to: 'foamrequests#approve_request'
  get 'approve_request_index', to: 'foamrequests#approve_request_index'
  get 'set_approved', to: 'foamrequests#set_approved'  
  
  get 'prepare_request_index', to: 'foamrequests#prepare_request_index'
  get 'prepare_component', to: 'foamrequests#prepare_component'  
  get 'get_manual_batch', to: 'foamrequests#get_manual_batch'
  get 'set_manual_batch', to: 'foamrequests#set_manual_batch'
  get 'set_prepared_summary', to: 'foamrequests#set_prepared_summary'  
  get 'summary_report', to: 'foamrequests#summary_report'  
  get 'picklist_report', to: 'foamrequests#picklist_report'  
  get 'finish_preparation', to: 'foamrequests#finish_preparation'  

  # Without Barcode
  get 'use_prepared_request', to: 'foamrequests#use_prepared_request'
  get 'use_prepared_request_step2', to: 'foamrequests#use_prepared_request_step2'
  get 'use_prepared_request_step3', to: 'foamrequests#use_prepared_request_step3'

  # With Barcode
  get 'use_prepared_request_index', to: 'foamrequests#use_prepared_request_index'
  get 'search_material_request', to: 'foamrequests#search_material_request'
  get 'search_container_id', to: 'foamrequests#search_container_id'

  # Unloading Containers
  get 'unloading_container_index', to: 'foamrequests#unloading_container_index'
  get 'set_unloadable_quantity', to: 'foamrequests#set_unloadable_quantity'
  get 'search_container_id_unloading', to: 'foamrequests#search_container_id_unloading'
  get 'save_unloading_record', to: 'foamrequests#save_unloading_record'

  #Inventory requests (Készletáttárolás)
  get 'inventory_request_index', to: 'inventoryrequests#inventory_request_index' 
  get 'check_internal_label_ir', to: 'inventoryrequests#check_internal_label_ir'
  get 'get_storage_id_ir',       to: 'inventoryrequests#get_storage_id_ir'
  get 'check_storage_id_ir',     to: 'inventoryrequests#check_storage_id_ir'
  get 'set_storage_id_ir',       to: 'inventoryrequests#set_storage_id_ir'
end

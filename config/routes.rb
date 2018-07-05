Rails.application.routes.draw do

  get 'id_card_import_files/' => 'id_card_import_files#index'
  get 'id_card_import_files/new'
  match 'id_card_import_files/' => 'id_card_import_files#create', :via => :post
  resources :id_card_import_files
  resources :id_card_import_results

  match 'self_iccards/t' => 'self_iccards#translate_from_tag', :via => :post
  resources :self_iccards
end

Rails.application.routes.draw do

  get 'id_card_import_files/' => 'id_card_import_files#index'
  get 'id_card_import_files/new'
  match 'id_card_import_files/' => 'id_card_import_files#create', :via => :post
  resources :id_card_import_files
  resources :id_card_import_results

  match 'id_cards/t' => 'id_cards#translate', :via => :post
  resources :id_cards
end

ActionController::Routing::Routes.draw do |map|
  map.namespace :admin do |admin|
    admin.resources :form_datas do |form_data|
      form_data.resources :form_data_assets
    end
  end
end
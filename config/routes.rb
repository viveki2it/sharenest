require 'sidekiq/web'
Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  mount Sidekiq::Web, at: '/sidekiq', as: 'sidekiq'
  scope "(:locale)", locale: /#{I18n.available_locales.join("|")}/ do
    root :to => "users#new"

    post 'users/create' => 'users#create'
    get 'refer-a-friend' => 'users#refer'
    get 'terms-service' => 'users#terms'
    get 'privacy-policy' => 'users#policy'
    
    resources :users, only: [:show]

    unless Rails.application.config.consider_all_requests_local
      get '*not_found', to: 'users#redirect', :format => false
    end
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end

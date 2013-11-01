Mybusa::Application.routes.draw do
  root :to => "home#index"

  ActiveAdmin.routes(self)

  resources :opportunities, :only => [:index, :show]
  get 'find-opportunities', to: 'opportunities#index', as: :find_opportunities

  resources :sbir_solicitations

  resource :profile do
    resources :profile_people, as: 'people'
  end

  resources :sbir_apps

  get '/auth/:provider/callback' => 'sessions#create'
  get '/signin' => 'sessions#new', :as => :signin
  get '/signout' => 'sessions#destroy', :as => :signout
  get '/auth/failure' => 'sessions#failure'
end

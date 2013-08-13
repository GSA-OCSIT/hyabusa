Mybusa::Application.routes.draw do
  root :to => "home#index"
  resources :users, :only => [:index, :show, :edit, :update ]

  resources :opportunities, :only => [:index, :show]
  get '/opportunities/mo/:mo_id' => 'opportunities#show_mo'
  get 'find-opportunities', to: 'opportunities#index', as: :find_opportunities

  get '/auth/:provider/callback' => 'sessions#create'
  get '/signin' => 'sessions#new', :as => :signin
  get '/signout' => 'sessions#destroy', :as => :signout
  get '/auth/failure' => 'sessions#failure'
end

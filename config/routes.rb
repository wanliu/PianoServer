Rails.application.routes.draw do
  concern :messable do
    resources :messages
  end

  concern :roomable do 
    resources :rooms, concerns: :messable do 
      collection do 
        put "negotiate_with/:user_id", to: "rooms#negotiate_with"
      end

      member do 
        put "accepting", to: "rooms#accepting"
      end
    end
  end

  # concern :chatable do 
  #   resources :chats
  # end

  devise_for :users, controllers: {
      sessions: 'users/sessions',
      registrations: 'users/registrations'
    }

  namespace :admin do
    resources :dashboards
  end

  namespace :api do 

    get "suggestion", :to => "suggestion#index"

    # resources :business, concerns: :roomable do 
    #   member do
    #     post :add_participant
    #   end
    # end
  end

  resources :promotions do 
    member do
      put "favorited", to: "promotions#favrited"
      get 'chat'
    end
  end
    
  resources :shops, only: [ :show ]
  resources :shop_categories, only: [ :index, :show ]
  resources :items, only: [ :index, :show ]
  ## shop route
  #
  match ':shop_name', :to => 'shops#show_by_name', via: [ :get ]

  root to: "promotions#index"
end

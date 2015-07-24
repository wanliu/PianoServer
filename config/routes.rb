Rails.application.routes.draw do
  mount ChinaCity::Engine => '/china_city'  
  resources :contacts, only: [:new, :show, :create, :destroy]

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
    get 'contacts' => 'contacts#index'
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
      get 'status/:order_id', to: "promotions#status", as: :status_of
    end
  end

  resources :shops, only: [ :show ]
  ## shop route
  #
  get '/about' => 'home#about'

  match ':shop_name', :to => 'shops#show_by_name', via: [ :get ]


  root to: "promotions#index"
end

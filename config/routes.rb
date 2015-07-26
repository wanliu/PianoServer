Rails.application.routes.draw do
  devise_for :admins, controllers: {
    sessions: 'admins/sessions',
    registrations: 'admins/registrations'
  }

  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations'
  }

  mount ChinaCity::Engine => '/china_city'
  resources :contacts, only: [:new, :show, :create, :destroy]

  concern :messable do
    resources :messages
  end

  concern :roomable do
    resources :rooms do
      collection do
        get 'channel/:channel_id', to: 'rooms#channel', as: :channel
        get 'owner/:owner_id', to: 'rooms#owner', as: :owner
        get 'target/:target_id', to: 'rooms#target', as: :target
        get 'token/:token_id', to: 'rooms#token'
      end
    end
  end

  # concern :chatable do
  #   resources :chats
  # end



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

  resources :promotions, concerns: :roomable do
    member do
      put "favorited", to: "promotions#favrited"
      get 'chat'
      get 'status/:order_id', to: "promotions#status", as: :status_of
      get 'shop/:shop_id', to: "promotions#shop", as: :shop
    end
  end

  resources :shops, concerns: :roomable, only: [ :show ]
  resources :rooms
  ## shop route
  #
  get '/about' => 'home#about'

  match ':shop_name', :to => 'shops#show_by_name', via: [ :get ]


  root to: "promotions#index"
end

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

  concern :chatable do
    resources :chats do
      collection do
        get 'channel/:channel_id', to: 'chats#channel', as: :channel
        get 'owner/:owner_id', to: 'chats#owner', as: :owner
        get 'target/:target_id', to: 'chats#target', as: :target
        get 'token/:token_id', to: 'chats#token'
      end
    end
  end

  namespace :admins do
    resources :dashboards
    resources :accounts, except: [:new, :edit] do
      collection do
        get 'search_wanliu_user', to: 'accounts#search_wanliu_user'
        put 'import/:wanliu_user_id', to: 'accounts#import', as: :import
      end
    end
    resources :promotions
    resources :messages
    resources :contacts
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
      get 'shop/:shop_id', to: "promotions#shop", as: :shop
    end
  end

  resources :shops, only: [ :show ]
  resources :chats
  ## shop route
  #
  get '/about' => 'home#about'

  match ':shop_name', :to => 'shops#show_by_name', via: [ :get ]


  root to: "promotions#index"
end

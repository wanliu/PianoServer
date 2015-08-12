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
    resources :chats
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

  resources :promotions, concerns: [ :chatable ] do
    member do
      put "favorited", to: "promotions#favrited"
      get 'shop/:shop_id', to: "promotions#shop", as: :shop
    end
  end

  resources :shops, only: [ :show ]

  resources :shop_categories, only: [ :index, :show ]

  resources :items, only: [ :index, :show ]

  resources :chats
  resources :orders do
    member do
      get 'status', to: "orders#status", as: :status_of
      get 'diff', to: "orders#diff", as: :diff
      post 'accept', to: "orders#accept", as: :accept
      post 'ensure', to: "orders#ensure", as: :ensure
      post 'cancel', to: "orders#cancel", as: :cancel
      post 'reject', to: "orders#reject", as: :reject

      get 'items', to: 'orders#items'
      put 'add_item', to: 'orders#add_item'
    end
  end
  ## shop route
  #
  get '/about' => 'home#about'

  # match ':shop_name', :to => 'shops#show_by_name', via: [ :get ], as: :shop_site
  # namespace :shops, path: '/',  constraints: { id: /[a-zA-Z.0-9_\-]+(?<!\.atom)/ }, only: []  do
  #   resources :admin #, module: 'shops'
  # end
  resources :shops, path: '/', only: [] do # constraints: { id: /[a-zA-Z.0-9_\-]+(?<!\.atom)/ }
  # scope '(:shop_name)/', prefix: :shops do

    member do
      get "/about", to: "shops#about"
    end

    namespace :admin, module: 'shops/admin' do
      get "/", to: "admin#dashboard", as: :index
      get "/profile", to: "admin#profile"

      resources :categories
      resources :items
    end
  end

  match '@:profile', :to => 'profile#username', as: :profile, via: [ :get ]


  root to: "promotions#index"
end

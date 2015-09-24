Rails.application.routes.draw do
  mount Bootsy::Engine => '/bootsy', as: 'bootsy'
  resources :subjects, except: [:index, :new, :edit] do
    member do
      get "preview", to: 'subjects#preview', as: :preview
    end
  end

  namespace :authorize do
    get :weixin
    get :weixin_redirect_url
  end

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

  match "admins", to: "admins/dashboards#index", via: :get

  namespace :admins do
    resources :dashboards
    resources :accounts, except: [:new, :edit] do
      collection do
        get 'search_wanliu_user', to: 'accounts#search_wanliu_user'
        put 'import/:wanliu_user_id', to: 'accounts#import', as: :import
      end
    end
    resources :promotions
    resources :subjects do
      resources :templates do
        member do
          post :upload
          post :preview
        end

        collection do
          post :preview, to: 'templates#preview_new'
        end

        resources :variables, except: [:new ] do
          collection do
            get :new_promotion_variable
            get :new_promotion_set_variable
            get :search_promotion
          end
        end
      end
    end
    resources :messages
    resources :contacts
    resources :attachments
    resources :industries do
      collection do
        post :sync_es_brands
        post :sync_es_categories
      end

      resources :categories do
        resources :properties

        member do
          post :add_property
          patch :update_property
          delete :remove_property
          get :show_inhibit
          get :hide_inhibit
          get :children
        end
      end
    end

    resources :products
    resources :properties
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
      post "toggle_follow"
      get 'shop/:shop_id', to: "promotions#shop", as: :shop
    end
  end

  resources :categories

  resources :shops, only: [ :show ]

  resources :chats
  resources :orders do
    member do
      get 'status', to: "orders#status", as: :status_of
      get 'diff', to: "orders#diff", as: :diff
      post 'accept', to: "orders#accept", as: :accept
      post 'ensure', to: "orders#ensure", as: :ensure
      post 'cancel', to: "orders#cancel", as: :cancel
      post 'reject', to: "orders#reject", as: :reject
      put 'set_address', to: "orders#set_address"
      get 'items', to: 'orders#items'
      put 'add_item', to: 'orders#add_item'
    end
  end

  resources :locations do
    collection do
      put 'user_default_address', to: "locations#user_default_address"
    end
  end
  ## shop route
  #
  get '/about' => 'home#about'

  match ':shop_name', :to => 'shops#show_by_name', constraints: { id: /[a-zA-Z.0-9_\-]+(?<!\.atom)/ }, via: [ :get ], as: :shop_site

  resources :shops, path: '/', only: [], constraints: { id: /[a-zA-Z.0-9_\-]+(?<!\.atom)/ } do
    member do
      get "/about", to: "shops#about"
    end

    resources :shop_categories
    resources :items

    namespace :admin, module: 'shops/admin' do
      get "/", to: "dashboard#index", as: :index
      resource :profile do
        post :upload_shop_logo
      end

      resources :dashboard
      resources :shop_categories, constraints: { id: /[a-zA-Z.0-9_\-]+(?<!\.atom)/ } do
        member do
          get "/:child_id", to: "shop_categories#show_by_child", as: :child
          post "/:parent_id", to: "shop_categories#create_by_child"
          put "/:child_id", to: "shop_categories#update_by_child"
          post "/:child_id/upload_image", to: "shop_categories#upload_image"
          delete "/:child_id", to: "shop_categories#destroy_by_child"
        end
      end

      resources :items do

        collection do
          get "load_categories", to: "items#load_categories"
          get "/new/step1",  to: "items#new_step1"
          post "/new/step1", to: "items#commit_step1"
          get "/new/step2/category/:category_id", to: "items#new_step2", as: :with_category
          post "/new/step2/category/:category_id", to: "items#create"
        end
      end
    end
  end

  match '@:profile', :to => 'profile#username', as: :profile, via: [ :get ]


  root to: "promotions#index"
end

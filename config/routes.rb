Rails.application.routes.draw do

  resources :order_items, except: [:new, :edit]
  concern :messable do
    resources :messages
  end

  concern :chatable do
    resources :chats
  end

  concern :statuable do
    member do
      get :status
    end
  end

  resources :industry, only: [ :show ] do
    member do
      get :brands, as: :brands
      get "shops", to: "industry#shops", as: :shops
      get "region/:region_id",  to: "industry#region", as: :region
      get "categories", to: "industry#categories", as: :categories
    end
  end
  resources :regions, only: [ :index, :update ] do
    collection do
      post :set, as: :set
      post :retrive, as: :retrive
    end
  end

  #   post "/", to: "carts#add"
  #   delete "/:id", to: "carts#remove"

  #   post "commit", to: "carts#commit"
  # end

  resource :cart

  mount Bootsy::Engine => '/bootsy', as: 'bootsy'
  resources :subjects, except: [:index, :new, :edit] do
    member do
      get "preview", to: 'subjects#preview', as: :preview
    end
  end

  resources :brands, only: [ :index, :update ] do
    collection do
      get :filter
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
    registrations: 'users/registrations',
    passwords: 'users/passwords'
  }

  mount ChinaCity::Engine => '/china_city'
  resources :contacts, only: [:new, :show, :create, :destroy]

  resources :feedbacks


  resources :after_registers, concerns: [:statuable]

  concern :templable do |options|
    resources :templates, options do
      collection do
        post :preview, to: 'templates#preview_new'
        post :upload, as: :upload
        get :search
      end

      member do
        post :upload, as: :upload
        post :preview
      end

      resources :variables, host_type: 'Template', except: [:new ] do
        collection do
          get :new_promotion_variable
          get :new_promotion_set_variable
          get :search_promotion
        end
      end
    end

    resources :templates, options.merge(path: 'templates/blob', only: [:show], constraints: {id: /[\S]+/})
  end

  match "admins", to: "admins/dashboards#index", via: :get

  namespace :admins do
    resources :settings, path: 'settings/key', only: [:show, :update], constraints: {id: /[\S]+/}
    resources :dashboards
    resources :accounts, except: [:new, :edit] do
      collection do
        get 'search_wanliu_user', to: 'accounts#search_wanliu_user'
        put 'import/:wanliu_user_id', to: 'accounts#import', as: :import
      end
    end
    resources :regions
    resources :promotions
    resources :subjects do
      concerns :templable, templable_type: 'Subject', parent_type: 'Subject'
    end
    resources :messages
    resources :contacts
    resources :feedbacks
    resources :attachments
    resources :industries do
      concerns :templable, templable_type: 'Industry', parent_type: 'Industry'

      collection do
        post :upload, as: :upload

        get "categories", to: "industries#categories", as: :categories

        post :sync_es_brands
        post :sync_es_categories
      end

      member do
        post :upload, as: :upload
      end

      resources :categories do
        concerns :templable, templable_type: 'Category', parents_type: [ 'Industry', 'Category' ]
        resources :properties do
          collection do
            get "fuzzy_match", to: "properties#fuzzy_match"
          end
        end

        member do
          post :add_property
          patch :update_property
          delete :remove_property
          get :show_inhibit
          get :hide_inhibit
          get :children
          post :write_item_desc
          get :read_item_desc
          put :resort
        end
      end
    end

    resources :products
    resources :properties

    resources :units
    # resources :shops
    resources :brands do
      member do
        post "upload", as: :upload
      end

      collection  do
        post "upload", as: :upload
      end
    end
  end

  namespace :api do
    resources :user, only: [:index]
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

  resources :items, concerns: [ :chatable ]

  resources :cart_items, only: [:index, :show, :create, :update, :destroy]

  resources :categories
  resources :units, only: [:index, :show]

  resources :chats
  resources :intentions do
    member do
      get 'status', to: "intentions#status", as: :status_of
      get 'diff', to: "intentions#diff", as: :diff
      post 'accept', to: "intentions#accept", as: :accept
      post 'ensure', to: "intentions#ensure", as: :ensure
      post 'cancel', to: "intentions#cancel", as: :cancel
      post 'reject', to: "intentions#reject", as: :reject
      put 'set_address', to: "intentions#set_address"
      get 'items', to: 'intentions#items'
      put 'add_item', to: 'intentions#add_item'
    end
  end

  resources :orders, only: [:index, :show, :destroy, :create, :update] do
    collection do
      post "confirmation"
      post "buy_now_create"
      post "buy_now_confirm"
      get "history"
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

  match '@:profile', :to => 'profile#username', as: :profile, via: [ :get ]

  match ':shop_name', :to => 'shops#show_by_name', constraints: { id: /[a-zA-Z.0-9_\-]+(?<!\.atom)/ }, via: [ :get ], as: :shop_site

  match "create_shop", to: "shops#create", via: [:post], as: :create_shop
  match "update_name", to: "shops#update_name", via: [:put], as: :update_shop

  resources :shops, path: '/', only: [], constraints: { id: /[a-zA-Z.0-9_\-]+(?<!\.atom)/ } do
    member do
      get "/about", to: "shops#about"
    end


    resources :shop_categories, path: "categories"
    resources :items, key: :sid

    namespace :admin, module: 'shops/admin' do
      get "/", to: "dashboard#index", as: :index
      resource :profile do
        post :upload_shop_logo
      end

      resources :dashboard
      resources :shop_categories,  path: "categories", constraints: { id: /[a-zA-Z.0-9_\-]+(?<!\.atom)/ } do
        member do
          get "/:child_id", to: "shop_categories#show_by_child", as: :child
          get "/:child_id/new", to: "shop_categories#new_by_child"
          get "/:child_id/edit", to: "shop_categories#edit"
          post "/:parent_id", to: "shop_categories#create_by_child"
          put "/:child_id", to: "shop_categories#update_by_child"
          put "/:child_id/update_status", to: "shop_categories#update_status"
          patch "/:child_id", to: "shop_categories#update_category"
          post "/:child_id/upload_image", to: "shop_categories#upload_image"
          post "/:parent_id/upload_image_by_child", to: "shop_categories#upload_image_by_child"
          delete "/:child_id", to: "shop_categories#destroy_by_child"
        end
      end

      resources :items, key: :sid do
        collection do
          # get "load_categories", to: "items#load_categories"
          get "/new/step1",  to: "items#new_step1"
          post "/new/step1", to: "items#commit_step1"
          get "/new/step2/category/:category_id", to: "items#new_step2", as: :with_category
          post "/new/step2/category/:category_id", to: "items#create"
          post "/upload_image", to: "items#upload_image"
          put "/inventory_config", to: "items#inventory_config"
        end

        member do
          post "/upload_image", to: "items#upload_image_file"
          put "/change_sale_state", to: "items#change_sale_state"
          put "/inventory_config", to: "items#inventory_config"
        end
      end

      resources :orders, except: [:edit, :new, :create] do
        collection do
          get 'history'
        end
      end

      resources :settings do
        collection do
          put "/change_shop_theme", to: "settings#change_shop_theme"
          post "/upload_shop_poster", to: "settings#upload_shop_poster"
        end
      end
    end
  end

  root to: "promotions#index"
end

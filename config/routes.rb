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
      put 'chat'
    end
  end

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
  #   
  root to: "promotions#index"
end

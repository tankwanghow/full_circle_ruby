FullCircle::Application.routes.draw do

  match 'login' => 'sessions#new', as: :login
  match 'logout' => 'sessions#destroy', as: :logout
  match 'signup' => 'users#new', as: :signup
  match 'search' => 'main#index', as: :search
  match 'transactions' => 'transactions#index', as: :transactions
  
  root to: 'main#index'
  resources :audit_logs, only: :index

  resources :particular_types, only: [:new, :edit, :update, :create, :destroy]
  get 'particular_type/new_or_edit' => 'particular_types#new_or_edit'

  resources :products, only: [:new, :edit, :update, :create, :destroy]
  get 'product/get_unit' => 'products#get_unit'
  get 'product/new_or_edit' => 'products#new_or_edit'

  resources :users, only: [:new, :edit, :update, :create, :destroy]
  resources :accounts, only: [:new, :edit, :update, :create, :destroy]
  resources :account_types, only: [:new, :edit, :update, :create, :destroy]
  resource :sessions, only: [:new, :create, :destroy]
  resources :addresses, only: [:new, :edit, :update, :create, :destroy]

  resources :payments, only: [:new, :edit, :update, :create, :show] do
    resources :journal_entries, only: [:index]
  end
  get 'payment/new_or_edit' => 'payments#new_or_edit'

  resources :invoices, only: [:new, :edit, :update, :create, :show] do
    resources :journal_entries, only: [:index]
  end
  get 'invoice/new_or_edit' => 'invoices#new_or_edit'

  resources :packagings, only: [:new, :edit, :update, :create, :destroy]
  get 'packaging/new_or_edit' => 'packagings#new_or_edit'

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
    # resources :products

  # Sample resource route with options:
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

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end

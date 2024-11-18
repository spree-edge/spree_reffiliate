Spree::Core::Engine.routes.draw do
  get 'r/:code' => 'reffiliate#referral', as: 'referral'
  get 'a/:path' => 'reffiliate#affiliate', as: 'affiliate'
  get 'account/referral_details' => 'users#referral_details'

  namespace :api do
    namespace :v2 do
      namespace :storefront do
        resources :confirmations, only: [:new, :create], controller: 'confirmations' do
          collection do
            get :new
            post :create
          end
        end
      end
    end
  end

  namespace :admin do
    resources :affiliates do
      resources :commissions do
        patch :pay, on: :member
      end
      get :transactions, on: :member
    end

    resource :referral_settings, only: [:edit, :update]

    resources :commission_rules
  end
end

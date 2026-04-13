Rails.application.routes.draw do
  get 'up' => 'rails/health#show', as: :rails_health_check

  namespace :api do
    resources :users, only: %i[index show create] do
      member do
        resources :orders, only: %i[index show create], param: :order_id do
          member do
            post :complete
            post :cancel
          end
        end
      end
    end
  end
end

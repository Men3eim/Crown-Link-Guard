Rails.application.routes.draw do
  root to: redirect("/admin")

  namespace :api do
    namespace :v1 do
      get :health, to: "health#show"
      post :scan_url, to: "url_scans#create"
      post :reports, to: "reports#create"
      post :actions, to: "actions#create"
      match "*path", to: "health#show", via: :options
    end
  end

  namespace :admin do
    root to: "dashboard#index"
    get :login, to: "sessions#new"
    post :login, to: "sessions#create"
    delete :logout, to: "sessions#destroy"

    resources :url_scans, only: %i[index show] do
      member do
        post :allow_domain
        post :block_domain
      end
    end

    resources :reports, only: %i[index show update] do
      member do
        post :allow_domain
        post :block_domain
      end
    end

    resources :allowlisted_domains, only: %i[index create update destroy]
    resources :blocked_domains, only: %i[index create update destroy]
    get :settings, to: "settings#index"
    patch :settings, to: "settings#update"
    put :settings, to: "settings#update"
    resources :audit_logs, only: %i[index]
  end
end

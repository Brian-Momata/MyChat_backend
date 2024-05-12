Rails.application.routes.draw do
  mount ActionCable.server => "/cable"

  devise_for :users, paths: '', path_names: {
    sign_in: 'login',
    sign_out: 'logout',
    registration: 'signup'
  },
  controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations'
  }

  resources :users
  resources :messages do
    collection do
      get 'fetch', to: 'messages#fetch_messages'
    end
  end
  post "/user/send_message", to: "users#send_message"
  post "/user/avatar", to: "users#update_avatar"
  get "/user/sent_messages", to: "users#sent_messages"
  get "/user/latest_between_users", to: "users#latest_between_users"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end

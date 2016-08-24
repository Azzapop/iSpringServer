Rails.application.routes.draw do
  root 'results#index'
  resources :results
  post "/parse", to: "results#parse"
end

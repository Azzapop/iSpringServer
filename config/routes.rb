Rails.application.routes.draw do
  root 'results#stars'
  resources :results
  post "/parse", to: "results#parse"
end

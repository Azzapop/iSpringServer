Rails.application.routes.draw do
  get 'results/parse'

  post '/parse', to: 'results#parse'
end

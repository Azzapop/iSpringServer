Rails.application.routes.draw do
  post '/parse', to: 'results#parse'
end

Mapz::Application.routes.draw do
  resources :timelines, only: :index
  resources :states, only: :index
  resources :shows, only: :index

  match '/ui(/:action)', controller: 'ui'

  root to: 'ui#timeline'
end

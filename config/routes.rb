Mapz::Application.routes.draw do
  resources :timelines, only: :index
  match '/ui(/:action)', controller: 'ui'
  root to: 'ui#map'
end

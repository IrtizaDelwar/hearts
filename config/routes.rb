Rails.application.routes.draw do
  resources :players, param: :name
  resources :games
  
  get 'hearts_ladder/hearts'
  get 'players/index'
  get 'games/index'
  get 'players/show'
  root 'players#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end

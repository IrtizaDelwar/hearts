Rails.application.routes.draw do
  resources :games, :players
  
  get 'hearts_ladder/hearts'
  get 'players/index'
  get 'games/index'
  root 'players#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end

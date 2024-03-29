Rails.application.routes.draw do
  resources :players, param: :name
  resources :games
  resources :league_stats, param: :include_player
  resources :poker_players, param: :name
  resources :p_games
  resources :poker_stats
  resources :season_rankings, param: :season
  resources :tournaments
  
  get 'hearts_ladder/hearts'
  get 'players/index'
  get 'games/index'
  get 'players/show'
  get 'league_stats/index'
  get 'league_stats/show'
  post 'league_stats/new' => 'league_stats#custom'
  get 'hearts_ai/index'
  root 'players#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end

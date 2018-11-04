class PlayersController < ApplicationController
  def index
    @player = Player.order('players.elo DESC').all
  end

  def new
    @player = Player.new
  end

  def create(player_params)
    @player = Player.new(player_params)
    if @player.save
      #next
    else
      redirect_to 'games/new'
    end
  end

  def redo_elo()
    Players.delete_all;
    Games.each do |game|
        game.validate_player
    end
  end	
end

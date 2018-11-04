class GamesController < ApplicationController
  def index
    @game = Game.all
  end

  def new
    @game = Game.new
  end

  def create
    @game = Game.new(game_params)
    if @game.save
      redirect_to '/games/new'
    else
      redirect_to '/games/new'
    end
  end

  private
    def game_params
      params.require(:game).permit(:game_id, :winner, :losers)
    end
end

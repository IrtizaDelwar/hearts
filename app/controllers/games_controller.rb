class GamesController < ApplicationController
  def index
    @game = Game.all
  end

  def new
    @game = Game.new
  end

  def create
    @game = Game.new(game_params)
    puts "TESTING" + game_params.to_s
    if @game.save
      redirect_to '/games/'
    else
      redirect_to '/games/new'
    end
  end

  private
    def game_params
      params.require(:game).permit(:game_id, :winner, :losers, :elochange)
    end
end

class PlayersController < ApplicationController
  def index
    @player = Array.new
    @unranked_player = Array.new
    dbPlayer = Player.order('players.elo DESC').all
    dbPlayer.each do |p|
      if p.wins + p.losses >= 5
        @player.push(p)
      else
        @unranked_player.push(p)
      end
    end
  end

  def new
    @player = Player.new
  end

  def create
    @player = Player.new(player_params)
    if @player.save
      redirect_to '/players/'
    else
      render 'new'
    end
  end

  def show
    @player = Player.find_by(name: params[:name])
    @last5 = Game.where(winner: params[:name]).or(Game.where("losers LIKE :name", {:name => "%#{params[:name]}%"})).order('games.created_at DESC')
    @vs_stats = versus_stats()
  end

  def versus_stats
    vs_players = Hash.new
    Player.all.each do |p|
      if p == @player
        next
      end
      hash = { p.name => { "wins" => 0, "losses" => 0}}
      vs_players.merge!(hash)
    end
    @last5.each do |game|
      losers = game.losers.to_s.split(",")
      if game.winner == @player.name
        losers.each do |l|
          vs_players[l]["wins"] += 1
        end
      else
        vs_players[game.winner]["losses"] += 1
        losers.each do |l|
          if l == @player.name
            next
          else
            vs_players[l]["losses"] += 1
          end
        end
      end
    end
    vs_players
  end

  private
    def player_params
      params.require(:player).permit(:name, :elo, :wins, :losses)
    end
end

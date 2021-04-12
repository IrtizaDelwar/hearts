class PokerPlayersController < ApplicationController
  def index
    @player = PokerPlayer.where("games > 0").order('poker_players.elo DESC').all
    @elo_champs = ["Tyler", "Irtiza"]
    @tourny_champs =["CJ"]
  end

  def new
    @player = PokerPlayer.new
  end

  def create
    @player = PokerPlayer.new(player_params)
    if @player.save
      redirect_to '/poker_players/'
    else
      render 'new'
    end
  end

  def show
    @player = PokerPlayer.find_by(name: params[:name])
    cash_outs = CashOut.all
    history = PGame.all.order('p_games.id ASC')
    @eloHistory = Array.new
    @eloChart = Array.new
    @net_cash = Array.new

    player_elo = Hash.new
    PokerPlayer.all.each do |p|
      player_elo[p.name] = 1200
    end
    @matches = Array.new
    @eloHistory.unshift(1200)
    history.each do |match|
      game_id = match.id
      players_in_game = Hash.new
      player_buyins = Hash.new
      new_player_elo = Hash.new
      match_stats = cash_outs.select {|c| c.p_game_id == game_id}
      total_chips = match_stats.pluck(:buyin).inject(0, :+)
      match_stats.each do |m|
        players_in_game[m.name] = player_elo[m.name]
        player_buyins[m.name] = ( m.buyin / 100 )
      end
      total_rating = players_in_game.map {|k,v| player_buyins[k] * (10 ** (v / 400))}.inject(0, :+)

      players_in_game.each do |name, elo|
        player_game_results = match_stats.select{ |m| name == m.name}
        player_rating = (10 ** (elo / 400)) * ( player_game_results.pluck(:buyin)[0] / 100 )
        expected_chip_percent = player_rating.to_f / total_rating.to_f
        actual_chip_percent = player_game_results.pluck(:buyout)[0].to_f / total_chips.to_f
        new_elo = elo + ((5*(total_chips/100)) * (actual_chip_percent - expected_chip_percent))
        if name == @player.name
          @net_cash << [(new_elo - player_elo[name]).to_i, (player_game_results.pluck(:buyout)[0] - player_game_results.pluck(:buyin)[0]), game_id]
        end
         player_elo[name] = new_elo
         @eloHistory.unshift(player_elo[@player.name].to_i)
      end
      @eloChart << [(match.id - 5), player_elo[@player.name].to_i]
      @minElo = @eloHistory.min
      @maxElo = @eloHistory.max
      @matches = player_elo
      @net_cash = @net_cash
    end
  #   @last5 = Game.where(winner: params[:name]).or(Game.where("losers LIKE :name", {:name => "%#{params[:name]}%"})).order('games.created_at DESC')
  #   @vs_stats = versus_stats()
  #   history = @last5.reverse
  #   currentElo = 1200

  #   game = Game.new
  #   history.each do |game|
  #     if game.winner == @player.name
  #       currentElo = currentElo + game.elochange.split(",").map(&:to_f).inject(0, :+)
  #     else
  #       player_index = game.losers.split(",").index(@player.name)
  #       currentElo = currentElo - game.elochange.split(",")[player_index].to_f
  #     end
  #     puts currentElo
  #      @eloHistory.unshift(currentElo.to_i)
  #      @eloChart << [game.created_at.to_date, currentElo.to_i]
  #   end
  #   @minElo = @eloHistory.min
  #   @maxElo = @eloHistory.max
  end

  # def versus_stats
  #   vs_players = Hash.new
  #   Player.all.each do |p|
  #     if p == @player
  #       next
  #     end
  #     hash = { p.name => { "wins" => 0, "losses" => 0}}
  #     vs_players.merge!(hash)
  #   end
  #   @last5.each do |game|
  #     losers = game.losers.to_s.split(",")
  #     if game.winner == @player.name
  #       losers.each do |l|
  #         vs_players[l]["wins"] += 1
  #       end
  #     else
  #       vs_players[game.winner]["losses"] += 1
  #       losers.each do |l|
  #         if l == @player.name
  #           next
  #         else
  #           vs_players[l]["losses"] += 1
  #         end
  #       end
  #     end
  #   end
  #   vs_players
  # end

  private
    def player_params
      params.require(:poker_player).permit(:name, :elo, :buyins, :cashout, :games)
    end
end

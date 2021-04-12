class PGamesController < ApplicationController

  def index
    @game = PGame.all
    @cashout = CashOut.all
  end

  def new
    @game = PGame.new
    @game_cashout = @game.cash_out.build
  end

  def show
    @game = PGame.find_by(id: params[:id])
    @cashouts = CashOut.all
    @game_cashouts = CashOut.where(p_game_id: params[:id])
    @total_cash = @game_cashouts.pluck(:buyin).inject(0, :+)
    if params[:id].to_i > 36 && params[:id].to_i < 118
      @previous_games = PGame.where("id < #{params[:id]} AND id > 36 AND id < 118").order('id ASC')
    elsif params[:id].to_i > 117 && params[:id].to_i < 185
      @previous_games = PGame.where("id < #{params[:id]} AND id > 117 AND id < 185").order('id ASC')
    elsif params[:id].to_i > 184 && params[:id].to_i < 246
      @previous_games = PGame.where("id < #{params[:id]} AND id > 184 AND id < 246").order('id ASC')
    elsif params[:id].to_i > 245 && params[:id].to_i < 306
      @previous_games = PGame.where("id < #{params[:id]} AND id > 245 AND id < 306").order('id ASC')
    elsif params[:id].to_i > 305
      @previous_games = PGame.where("id < #{params[:id]} AND id > 305")
    else
      @previous_games = PGame.where("id < #{params[:id]}").order('id ASC')
    end
    @game_elo = get_game_elo()
    @player_stats = new_elo()
    @game_pie = Array.new
    @game_cashouts.each do |c|
      @game_pie << [c.name, c.buyout]
    end
    @match_elo = (@player_stats.map{ |a| a[1]}.inject(:+) / @player_stats.size).to_i
  end

  def get_game_elo
    player_elo = Hash.new
    PokerPlayer.all.each do |p|
      player_elo[p.name] = 1200
    end
    @previous_games.each do |g|
      game_id = g.id
      players_in_game = Hash.new
      player_buyins = Hash.new
      new_player_elo = Hash.new
      match_stats = @cashouts.select {|c| c.p_game_id == game_id}
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
        player_elo[name] = new_elo
      end
    end
    return player_elo
  end

  def new_elo
    results = Array.new
    player_elo = @game_elo
    players_in_game = Hash.new
    player_buyins = Hash.new
    @game_cashouts.each do |m|
      players_in_game[m.name] = player_elo[m.name]
      player_buyins[m.name] = ( m.buyin / 100 )
    end
    total_rating = players_in_game.map {|k,v| player_buyins[k] * (10 ** (v / 400))}.inject(0, :+)
    players_in_game.each do |name, elo|
      player_game_results = @game_cashouts.select{ |m| name == m.name}
      player_rating = (10 ** (elo / 400)) * ( player_game_results.pluck(:buyin)[0] / 100 )
      expected_chip_percent = player_rating.to_f / total_rating.to_f
      actual_chip_percent = player_game_results.pluck(:buyout)[0].to_f / @total_cash.to_f
      new_elo = elo + ((5*(@total_cash.to_f/100))* (actual_chip_percent - expected_chip_percent))
      results << [name, player_elo[name], new_elo, player_game_results.pluck(:buyout)[0], expected_chip_percent, actual_chip_percent, player_game_results.pluck(:buyin)[0]]
    end
    return results
  end

  def create
    @game = PGame.new(game_params)
    if @game.save
      redirect_to '/p_games/'
    else
      redirect_to '/p_games/new'
    end
  end

  private
    def game_params
      params
      .require(:p_game)
      .permit(:p_game_id, cash_out_attributes: CashOut.attribute_names.map(&:to_sym).push(:_deestroy))
    end
end
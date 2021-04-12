class SeasonRankingsController < ApplicationController
  
  def show
    @season = params[:season]
    @cashouts = CashOut.all
    if @season == 'all'
      @games = PGame.all.order('id ASC')
    elsif @season == "1"
      @games = PGame.where("id <= 36").order('id ASC')
    elsif @season == "2"
      @games = PGame.where("id > 36 AND id <= 117").order('id ASC')
    elsif @season == "3"
      @games = PGame.where("id > 117 AND id <= 184").order('id ASC')
    elsif @season == "4"
      @games = PGame.where("id > 184 AND id <= 245").order('id ASC')
    elsif @season == "5"
      @games = PGame.where("id > 245 AND id <= 305").order('id ASC')
    elsif @season == "6"
      @games = PGame.where("id > 305")
    else
      raise 'Error we have not yet reached season #{@season}'
    end
    @stats = get_elo
    @elo_champs = ["Tyler", "Irtiza", "Ding", "Joe"]
    @tourny_champs =["CJ", "CJ", "Tyler"]
  end

  def get_elo
    player_elo = Hash.new
    
    PokerPlayer.all.each do |p|
      hash = {p.name => { "elo" => 1200, "elo2" => 1200, "buyin" => 0, "cashout" => 0, "games" => 0, "last5" => Array.new, "history" => Array.new}}
      player_elo.merge!(hash)
    end

    @games.each do |g|
      game_id = g.id
      players_in_game = Hash.new
      player_buyins = Hash.new
      new_player_elo = Hash.new
      match_stats = @cashouts.select {|c| c.p_game_id == game_id}
      total_chips = match_stats.pluck(:buyin).inject(0, :+)
      match_stats.each do |m|
        players_in_game[m.name] = player_elo[m.name]["elo2"]
        player_buyins[m.name] = ( m.buyin / 100 )
      end

      total_rating = players_in_game.map {|k,v| player_buyins[k] * (10 ** (v / 400))}.inject(0, :+)

      players_in_game.each do |name, elo|
        player_game_results = match_stats.select{ |m| name == m.name}
        player_rating = (10 ** (elo / 400)) * ( player_game_results.pluck(:buyin)[0] / 100 )
        expected_chip_percent = player_rating.to_f / total_rating.to_f
        actual_chip_percent = player_game_results.pluck(:buyout)[0].to_f / total_chips.to_f
        new_elo = elo + (50 * (actual_chip_percent - expected_chip_percent))
        new_elo2 = player_elo[name]["elo2"] + ((5*(total_chips/100)) * (actual_chip_percent - expected_chip_percent))
        player_elo[name]["last5"].unshift((new_elo2 - player_elo[name]["elo2"]))
        player_elo[name]["elo"] = new_elo
        player_elo[name]["elo2"] = new_elo2
        player_elo[name]["buyin"] += player_game_results.pluck(:buyin)[0].to_f
        player_elo[name]["cashout"] += player_game_results.pluck(:buyout)[0].to_f
        player_elo[name]["games"] += 1
        player_elo[name]["history"] << new_elo2
      end
    end
    player_elo = player_elo.select{ |key, value| value["games"] > 0}
    player_elo = player_elo.sort_by{|key, value| value["elo2"]}.reverse
    return player_elo
  end
end

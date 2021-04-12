  class LeagueStatsController < ApplicationController

  def index
    @players = Player.all
    @match_history = Game.order('games.created_at ASC')
    @players_elo_history = Array.new
    @elo_max = 1200
    @elo_min = 1200
    @elo_max_player = nil
    @elo_min_player = nil
    @max_win_streak = 0
    @max_win_streak_player = nil
    @max_lose_streak = 0
    @max_lose_streak_player = nil
    @player_sos = Array.new
    @largest_plus_elo = [nil, 0]
    @largest_minus_elo = [nil, 0]
    @players.each do |p|
      @players_elo_history << {:name => p.name, :data => get_elo_chart(p.name)}
    end
    win_rates_by_elo_position()
    get_filtered_win_rates()
    get_win_difficulty()
  end

  def new
    @games = Game.all
  end

  def show
    @stats = params[:include_player]
    #@stats = Game.where(winner: params[:player]).or(Game.where("losers LIKE :name", {:name => "%#{params[:player]}%"})).order('games.created_at DESC')
  end

  def get_elo_chart(player)
    elo_chart = Array.new
    currentElo = 1200
    max_win_streak = 0
    max_lose_streak = 0
    current_streak = "NONE"
    eloList = Array.new
    strength_of_schedule = Array.new
    elo_gained = 0
    elo_lost = 0
    @match_history.each do |game|
      table_total_elo = game.tableelo.split(",").map(&:to_f)
      if game.winner == player
        strength_of_schedule << ((table_total_elo.inject(0, :+) - table_total_elo[0]) / 3)
        elo_gained = game.elochange.split(",").map(&:to_f).inject(0, :+)
        currentElo = currentElo + elo_gained
        current_streak = streak(current_streak, "W")
      elsif game.losers.include? player
        player_index = game.losers.split(",").index(player) 
        strength_of_schedule << ((table_total_elo.inject(0, :+) - table_total_elo[player_index + 1]) / 3)
        elo_lost = game.elochange.split(",")[player_index].to_f
        currentElo = currentElo - elo_lost
        current_streak = streak(current_streak, "L")
      end
      eloList << currentElo.to_i
      elo_chart << [game.created_at.to_date, currentElo.to_i]
      max_win_streak = [max_win_streak, current_streak.tr('W', '').to_i].max
      max_lose_streak = [max_lose_streak, current_streak.tr('L', '').to_i].max
      @largest_plus_elo = elo_gained > @largest_plus_elo[1]? [player, elo_gained] : @largest_plus_elo
      @largest_minus_elo = elo_lost > @largest_minus_elo[1]? [player, elo_lost] : @largest_minus_elo
    end
    if eloList.max > @elo_max
      @elo_max = eloList.max
      @elo_max_player = player
    elsif eloList.max == @elo_max
      @elo_max_player = @elo_max_player + ", " + player
    end
    if eloList.min < @elo_min
      @elo_min = eloList.min
      @elo_min_player = player
    elsif eloList.min == @elo_min
      @elo_min_player = @elo_min_player + ", " + player
    end
    if max_win_streak > @max_win_streak
      @max_win_streak = max_win_streak
      @max_win_streak_player = player
    elsif max_win_streak == @max_win_streak
      @max_win_streak_player = @max_win_streak_player + ", " + player
    end
    if max_lose_streak > @max_lose_streak
      @max_lose_streak = max_lose_streak
      @max_lose_streak_player = player
    elsif max_lose_streak == @max_lose_streak
      @max_lose_streak_player = @max_lose_streak_player + ", " + player
    end
    @player_sos << [player, (strength_of_schedule.inject(0, :+) / (strength_of_schedule.size.nonzero? || 1)).to_i]
    elo_chart
  end

  def win_rates_by_elo_position
    @positional_win_rates = [0, 0, 0, 0]
    @match_history.each do |g|
      player_to_elo = Array.new
      all_players = g.losers.split(",").unshift(g.winner)
      all_players.each_with_index do |p, i|
        player_to_elo << [p, g.tableelo.split(",")[i]]
      end
      player_to_elo = player_to_elo.sort_by{|x,y|y}.reverse
      player_to_elo.each_with_index do |p, i|
        if g.winner == p[0]
          @positional_win_rates[i] += 1
        end
      end
    end
    @positional_win_rates.each_with_index do |p, i|
      @positional_win_rates[i] = [i+1, @positional_win_rates[i]]
    end
  end

  def streak(current, latest_result)
    if (current.include? "W") && (latest_result == "W")
      return "W" + (current.tr('W', '').to_i + 1).to_s
    elsif (current.include? "L") && (latest_result == "L")
      return "L" + (current.tr('L', '').to_i + 1).to_s
    else
      return latest_result + "1"
    end
  end

  def get_filtered_win_rates
    @match_history_above_mendoza = create_records(@match_history.select { |game| game.tableelo.split(",").map(&:to_i).inject(0, :+)/4 >= 1200 })
    @match_history_below_mendoza = create_records(@match_history.select { |game| game.tableelo.split(",").map(&:to_i).inject(0, :+)/4 < 1200 })
    @match_history_this_month = create_records(@match_history.select{ |game| game.created_at >= Time.now.at_beginning_of_month.utc })
    @match_history_last2_months = create_records(@match_history.select{ |game| game.created_at >= Time.now.ago(1.month).at_beginning_of_month.utc && game.created_at < Time.now.at_beginning_of_month.utc})
    @per_month_stats = get_top_winrate_month()
  end

  def get_top_winrate_month
    stats = Hash.new
    games_per_month = Game.all.group_by{ |u| u.created_at.at_beginning_of_month}
    games_per_month.each do |g|
      matches = create_records(g[1]).select{ |p| (p[1]["wins"] + p[1]["losses"]) >= 5}
      matches_elo = matches.sort_by{|x,y|y["elogain"]}.reverse
      if matches.size == 0
        next
      end
      hash = {g[0] => {"count" => g[1].count, "top" => matches.first[0], "winrate" => matches.first[1]["winrate"], "bottom" => matches.last[0], "bottom_winrate" => matches.last[1]["winrate"],
        "top_elo" => matches_elo.first[0], "top_elo_diff" => matches_elo.first[1]["elogain"], "bottom_elo" => matches_elo.last[0], 
        "bottom_elo_diff" => matches_elo.last[1]["elogain"]}}
      stats.merge!(hash)
    end
    stats
  end

  def create_records(match_history)
    record = Hash.new
    @players.each do |p|
      hash = { p.name => { "wins" => 0, "losses" => 0, "winrate" => 0.0, "elogain" => 0}}
      record.merge!(hash)
    end
    match_history.each do |g|
      record[g.winner]["wins"] += 1
      record[g.winner]["elogain"] += g.elochange.split(",").map(&:to_f).inject(0, :+)
      losers = g.losers.to_s.split(",")
      losers.each_with_index do |l, i|
        record[l]["losses"] += 1
        record[l]["elogain"] -= g.elochange.split(",")[i].to_f
      end
    end
    record.each do |p|
      if ((p[1]["wins"] + p[1]["losses"]) == 0)
        p[1]["winrate"] = 0.to_f
      else
        p[1]["winrate"] = p[1]["wins"].to_f / (p[1]["wins"] + p[1]["losses"]).to_f
      end
    end
    record = record.sort{|a, b| (a[1]["winrate"] <=> b[1]["winrate"]) == 0 ? ((a[1]["losses"] + a[1]["wins"]) <=> (b[1]["losses"] + b[1]["wins"])) : (a[1]["winrate"] <=> b[1]["winrate"]) }.reverse
    return record
  end

  def get_win_difficulty
    @test = "nope"
    @win_difficulty = Array.new
    @players.each do |p|
      wins = Array.new
      @match_history.each do |g|
        if p.name == g.winner
          table_elo = g.tableelo.split(",").map(&:to_f)
          wins << ((table_elo.inject(0, :+) - table_elo[0]) / 3).to_i
        end
      end
      if (wins.length > 0)
        p_win_diff = [p.name, (wins.inject(0, :+) / wins.length)]
      else
        p_win_diff = [p.name, 0]
      end
      @win_difficulty << p_win_diff
    end
  end

end
require 'rubygems'

PokerPlayer.all.each do |p|
  p.elo = 1200
  p.buyins = 0
  p.cashout = 0
  p.games = 0
  p.save
end
 
PGame.all.each do |g|
  poker_player = PokerPlayer.all
  players_in_game = Hash.new
  player_buyins = Hash.new
  cash_out = CashOut.where(p_game_id: g.id)
  total_chips = cash_out.pluck(:buyin).inject(0, :+)

  cash_out.each do |c|
    players_in_game[c.name] = poker_player.select{ |p| p.name == c.name }.pluck(:elo)[0]
    player_buyins[c.name] = ( c.buyin / 100 )
  end

  total_rating = players_in_game.map {|k,v| player_buyins[k] * (10 ** (v / 400))}.inject(0, :+)

  players_in_game.each do |name, elo|
    puts "--------------------"
    player_game_results = cash_out.select{ |c| name == c.name}
    player_rating = (10 ** (elo / 400)) * ( player_game_results.pluck(:buyin)[0] / 100 )
    expected_chip_percent = player_rating.to_f / total_rating.to_f
    actual_chip_percent = player_game_results.pluck(:buyout)[0].to_f / total_chips.to_f
    puts "#{name}: a-#{actual_chip_percent} and e-#{expected_chip_percent}"
    puts "#{name}: #{player_rating } and #{total_rating}"
    new_elo = elo + ((5*(total_chips/100)) * (actual_chip_percent - expected_chip_percent))
    puts new_elo
    puts "==="
    player = PokerPlayer.find_by name: name
    player.elo = new_elo
    player.buyins += player_game_results.pluck(:buyin)[0]
    player.cashout += player_game_results.pluck(:buyout)[0]
    player.games += 1
    player.save
  end


end

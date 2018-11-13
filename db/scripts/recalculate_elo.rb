require 'rubygems'

Player.destroy_all
Game.all.each do |g|
  winner = g.winner.to_s.gsub(/\s+/, "")
  losers_array = g.losers.to_s.split(",").map {|s| s.gsub(/\s+/, "") }
  players_array = Array.new
  players_array << winner
  players_array = players_array + losers_array
  game = Game.new
  game.validate_players_exist(players_array)
  elo_diff = game.calculate_and_update(winner, losers_array)
  puts "Adding elo"
  puts elo_diff
  g.update_attribute(:elochange, elo_diff)
  #g.save
end

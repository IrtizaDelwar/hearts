require 'rubygems'

Players.delete_all
Games.each do |g|
  winner = g.winner
  losers = g.losers
  losers_array = losers.to_s.split(",")
  game = Game.new
  game.calculate_and_update(win, losers_array)
end

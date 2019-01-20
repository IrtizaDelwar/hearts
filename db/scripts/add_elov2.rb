require 'rubygems'

def calculate_other_elo(player, all_players)
  total_elo = 0
  all_players.each do |p|
    if player.name == p["name"]
      next
    else
      total_elo += p["elo"]
    end
  end
  return total_elo / 3
end

Player.all.each do |p|
  p.elov2 = 1200
  p.wins = 0
  p.losses = 0
  p.save
end

Game.all.each do |g|
  winner = Player.find_by name: (g.winner.to_s.gsub(/\s+/, ""))
  all_players = Array.new
  table_elo = Array.new
  all_players << {"name" => winner.name, "elo" => winner.elov2}
  table_elo << winner.elov2
  losers_array = g.losers.to_s.split(",").map {|s| s.gsub(/\s+/, "") }
  losers = Array.new
  losers_array.each do |l|
    loser = (Player.find_by name: l)
    losers << loser
    all_players << {"name" => loser.name, "elo" => loser.elov2}
    table_elo << loser.elov2
  end
  
  g.update_attribute(:tableelo, table_elo.join(","))
  game = Game.new
  totalEloDiff = Array.new
  losers.each do |l|
    opponent_elo = calculate_other_elo(l, all_players)
    eloDiff = game.calculate_player(opponent_elo, l.elov2)
    puts l.name + " lost " + eloDiff.to_s
    totalEloDiff << eloDiff
    l.elov2 = l.elov2 - eloDiff
    l.losses += 1
    l.save
  end

  puts "Winner diff -> " + (winner.elov2 - calculate_other_elo(winner, all_players)).to_s
  puts "Winner " + g.winner + "losers " + g.losers
  puts totalEloDiff.inject(0, :+)
  winner.elov2 = winner.elov2 + totalEloDiff.inject(0, :+)
  winner.wins += 1
  winner.save
  puts "---Complete---"
  g.update_attribute(:elochange, totalEloDiff.join(","))
end


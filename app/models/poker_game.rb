class PokerGame < ApplicationRecord
  attr_accessor :cashout
  has_many :cashout
  accepts_nested_attributes_for :cashout
  auto_increment :id
  validate :create_cashout
  validates :cashout, presence: true

  def create_cashout
    self.cashout = [{name: self.name, buyin: self.buyin, buyout: self.buyout}]
  end

  #validates :cashout, presence: true
  #auto_increment :game_id
#   validate :validate_players 
#   validates :elochange, presence: true

#   def validate_players
#     self.winner = winner.to_s.gsub(/\s+/, "")
#     players_array = Array.new
#     players_array << winner
#     self.losers = losers.to_s.gsub(/\s+/," ")
#     losers_array = losers.split(",")
#     players_array = players_array + losers_array
#     if players_array.size != 4
#       raise "Invalid player count in game. Expected 4, but was " + players_array.size.to_s + losers.to_s
#     end
#     validate_players_exist(players_array)
#     elo_diff, table_elo = calculate_and_update(winner, losers_array)
#     self.elochange = elo_diff.join(",")
#     self.tableelo = table_elo
#   end

#   def validate_players_exist(players)
#     players.each do |p|
#       player = Player.find_by name: p
#       if player == nil
#         #errors.add(:game_id, "Player " + p + " does not exist. Please add player first.")
#         raise "Player " + p + " does not exist. Please add player first."
#         #Player.create({name: p, elo: 1200, wins: 0, losses: 0})
#       end
#     end
#   end

#   def calculate_and_update(win, lose)
#     winning_player = Player.find_by name: win
#     tableElo = Array.new
#     losing_players = Array.new
#     lose.each do |l|
#       losing_players << (Player.find_by name: l)
#     end
#     all_players = Array.new
#     all_players << {"name" => winning_player.name, "elo" => winning_player.elov2}
#     #Get starting elo
#     ##winnerStartElo = winning_player.elo
#     ##losersStartElo = 0
#     tableElo << winning_player.elov2
#     ##tableElo2 = winning_player.elov3
#     losing_players.each do |l|
#       ##losersStartElo += l.elo
#       tableElo << l.elov2
#       ##tableElo2 += l.elov3
#       all_players << {"name" => l.name, "elo" => l.elov2}
#     end
#     ##losersStartElo = losersStartElo / 3
#     tableElo = tableElo.join(",")

#     ##Transformed Rating
#     ##rWinner = 10**(winnerStartElo.to_f/400)
#     ##rLoser = 10**(losersStartElo.to_f/400)

#     ##Expected Rating
#     ##eWinner = rWinner / (rWinner + rLoser)
#     ##eLoser = rLoser / (rWinner + rLoser)

#     ##Rating Diff
#     ##winnerNewElo = winnerStartElo+50*(1-eWinner)
#     ##loserEloDiff = (winnerNewElo - winnerStartElo) / 3

#     #Update ELO and wins/losses
#     ##winning_player.elo = winnerNewElo
#     ##winning_player.elov3 = calculate_player(true, winning_player.elov3, winning_player.elov3, ((tableElo2-winning_player.elov3)/3))
#     #winning_player.elov2 = calculate_player(true, winning_player.elov2, winning_player.elov2, tableElo)
#     ##winning_player.save
#     totalEloDiff = Array.new #v2
#     losing_players.each do |l|
#       ##l.elo = l.elo - loserEloDiff
#       ##l.elov3 = calculate_player(false, l.elov3, ((tableElo2-l.elov3)/3), l.elov3)
#       #l.elov2 = calculate_player(false, l.elov2, tableElo, l.elov2)
#       l.losses += 1
#       opponent_elo = calculate_opponent_elo(l, all_players)
#       eloDiff = calculate_player(opponent_elo, l.elov2)
#       totalEloDiff << eloDiff
#       l.elov2 = l.elov2 - eloDiff
#       l.save
#     end
#     winning_player.elov2 = winning_player.elov2 + totalEloDiff.inject(0, :+)
#     winning_player.wins += 1
#     winning_player.save
#     return totalEloDiff, tableElo
#   end

#   # def calculate_player(win, playerElo, winnerStartElo, loserStartElo)

#   #   #Transformed Rating
#   #   rWinner = 10**(winnerStartElo.to_f/400)
#   #   rLoser = 10**(loserStartElo.to_f/400)

#   #   #Expected Rating
#   #   eWinner = rWinner / (rWinner + rLoser)
#   #   eLoser = rLoser / (rWinner + rLoser)

#   #   #Rating Diff
#   #   eloDiff = 50*(1-eWinner)

#   #   #Update ELO
#   #   if win
#   #     return (playerElo + eloDiff)
#   #   else
#   #     return (playerElo - (eloDiff / 3))
#   #   end
#   # end

#   def calculate_player(winnerStartElo, loserStartElo)

#     #Transformed Rating
#     rWinner = 10**(winnerStartElo.to_f/400)
#     rLoser = 10**(loserStartElo.to_f/400)

#     #Expected Rating
#     eWinner = rWinner / (rWinner + rLoser)
#     eLoser = rLoser / (rWinner + rLoser)

#     #Rating Diff
#     eloDiff = 50*(1-eWinner)
#     #Update ELO
#     return (eloDiff / 3)
#     # if win
#     #   puts eloDiff
#     #   return (winnerStartElo + eloDiff)
#     # else
#     #   puts (eloDiff / 3)
#     #   return (loserStartElo - (eloDiff / 3))
#     # end
#   end

#   def calculate_opponent_elo(player, all_players)
#     total_elo = 0
#     all_players.each do |p|
#       if player.name == p["name"]
#         next
#       else
#         total_elo += p["elo"]
#       end
#     end
#   return total_elo / 3
#   end

end
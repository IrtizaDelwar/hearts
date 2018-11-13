class Game < ApplicationRecord
  validates :winner, presence: true
  validates :losers, presence: true
  auto_increment :game_id
  validate :validate_players 
  validates :elochange, presence: true

  def validate_players
    self.winner = winner.to_s.gsub(/\s+/, "")
    players_array = Array.new
    players_array << winner
    self.losers = losers.to_s.gsub(/\s+/," ")
    losers_array = losers.split(",")
    players_array = players_array + losers_array
    if players_array.size != 4
      raise "Invalid player count in game. Expected 4, but was " + players_array.size.to_s + losers.to_s
    end
    validate_players_exist(players_array)
    elo_diff = calculate_and_update(winner, losers_array)
    puts
    self.elochange = elo_diff.to_s
    self.save
  end

  def validate_players_exist(players)
    players.each do |p|
      player = Player.find_by name: p
      if player == nil
        #errors.add(:game_id, "Player " + p + " does not exist. Please add player first.")
        #raise "Player " + p + " does not exist. Please add player first."
        Player.create({name: p, elo: 1200, wins: 0, losses: 0})
      end
    end
  end

  def calculate_and_update(win, lose)
    winning_player = Player.find_by name: win
    losing_players = Array.new
    lose.each do |l|
      losing_players << (Player.find_by name: l)
    end

    #Get starting elo
    winnerStartElo = winning_player.elo
    losersStartElo = 0
    losing_players.each do |l|
      losersStartElo += l.elo
    end
    losersStartElo = losersStartElo / 3

    #Transformed Rating
    rWinner = 10**(winnerStartElo.to_f/400)
    rLoser = 10**(losersStartElo.to_f/400)

    #Expected Rating
    eWinner = rWinner / (rWinner + rLoser)
    eLoser = rLoser / (rWinner + rLoser)

    #Rating Diff
    winnerNewElo = winnerStartElo+50*(1-eWinner)
    loserEloDiff = (winnerNewElo - winnerStartElo) / 3

    #Update ELO and wins/losses
    winning_player.elo = winnerNewElo
    winning_player.wins += 1
    winning_player.save
    losing_players.each do |l|
      l.elo = l.elo - loserEloDiff
      l.losses += 1
      l.save
    end
    return (winnerNewElo - winnerStartElo)
  end
end

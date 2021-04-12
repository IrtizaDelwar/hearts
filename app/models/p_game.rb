class PGame < ApplicationRecord
	has_many :cash_out, :dependent => :destroy
	accepts_nested_attributes_for :cash_out, :reject_if => lambda { |a| a[:name].blank? }, :allow_destroy => true
	validate :validate_players 
	before_save :calculate_elo

	def validate_players
		if self.cash_out.size < 2
			raise "Invalid Game. Not enough players."
		end
		unique_players = self.cash_out.uniq { |c| c.name }
		if unique_players.size != self.cash_out.size 
			raise "Invalid Game. A player cannot play more than once in a game."
		end
	end

	def calculate_elo
		poker_players = PokerPlayer.all
		players_in_game = Hash.new
    player_buyins = Hash.new
		total_chips = self.cash_out.to_a.pluck(:buyin).inject(0, :+)

		self.cash_out.each do |c|
			players_in_game[c.name] = poker_players.select{ |p| p.name == c.name }.pluck(:elo)[0]
      player_buyins[c.name] = ( c.buyin / 100 )
		end

		total_rating = players_in_game.map {|k,v| player_buyins[k] * (10 ** (v / 400))}.inject(0, :+)

		players_in_game.each do |name, elo|
			player_game_results = self.cash_out.select{ |c| name == c.name}
    		player_rating = (10 ** (elo / 400)) * ( player_game_results.pluck(:buyin)[0] / 100 )
    		expected_chip_percent = player_rating.to_f / total_rating.to_f
    		actual_chip_percent = player_game_results.pluck(:buyout)[0].to_f / total_chips.to_f
    		new_elo = elo + (50 * (actual_chip_percent - expected_chip_percent))
    		player = PokerPlayer.find_by name: name
    		player.elo = new_elo
    		player.buyins += player_game_results.pluck(:buyin)[0]
    		player.cashout += player_game_results.pluck(:buyout)[0]
    		player.games += 1
    		player.save
    	end
 	 end
end
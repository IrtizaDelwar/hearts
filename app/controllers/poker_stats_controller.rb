class PokerStatsController < ApplicationController

	def index
		@cashout = CashOut.all
		@player_positive_percentage = Hash.new
		@double_up_percentage = Hash.new
		@bankrupts_per_game = Hash.new
		@top_gains = Hash.new
		top_gains()
		get_win_percentage()
	end

	def get_win_percentage
		cashouts_per_player = @cashout.group_by { |p| p.name }
		cashouts_per_player.each do |p|
			positive_games = 0
			double_up_games = 0
			bankrupts = 0
			p[1].each do |g|
				if g.buyout > g.buyin
					positive_games += 1
				end
				if g.buyout >= (g.buyin * 2)
					double_up_games += 1
				end
				if g.buyout == 0 
					bankrupts += 1
				end
				if g.buyin > 100
					bankrupts += ((g.buyin - 100) / 100)
				end
			end
			if p[1].size > 4
				hash = { p[0] => { "positive_percent" => (positive_games.to_f / p[1].size.to_f)}}
      			@player_positive_percentage.merge!(hash)
      			hash = { p[0] => { "double_up_percent" => (double_up_games.to_f / p[1].size.to_f)}}
      			@double_up_percentage.merge!(hash)
      			hash = { p[0] => { "bankrupt_percent" => (bankrupts.to_f / p[1].size.to_f)}}
      			@bankrupts_per_game.merge!(hash)
      		end
		end
		@player_positive_percentage = @player_positive_percentage.sort_by { |k, v| v["positive_percent"]}.reverse
		@double_up_percentage = @double_up_percentage.sort_by { |k, v| v["double_up_percent"]}.reverse
		@bankrupts_per_game = @bankrupts_per_game.sort_by { |k, v| v["bankrupt_percent"]}.reverse
	end

	def top_gains
		@top_gains = @cashout.sort {|a, b| (a.buyout - a.buyin) <=> (b.buyout - b.buyin)}.reverse[0..9]
		# gains.each do |g|
		# 	hash = { g.name => { "gain" => (g.buyout - g.buyin)}}
  #     		@top_gains.merge!(hash)
  #     	end
	end

end
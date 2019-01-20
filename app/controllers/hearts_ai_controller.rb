# class HeartsAiController < ApplicationController
# 	def index
# 		@hearts = Hearts.new
# 		@scoreboard = @hearts.scoreboard
# 		@players = @hearts.players
# 		@trick
# 	end
# end

# class Deck
# 	attr_reader :cards
# 	def initialize
# 		@cards = []
# 		initialize_deck
# 	end

# 	def initialize_deck
# 		Cards::SUITS.each do |suit|
# 			Cards::FACES.each do |face|
# 				@cards << Cards.new(suit, face)
# 			end
# 		end
# 		@cards.shuffle!
# 	end

# end

# class Cards
# 	attr_reader :suit, :face
# 	SUITS = ['hearts', 'diamonds', 'clubs', 'spades']
# 	FACES = ['2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13', '14']

# 	def initialize(suit, face)
# 		@suit = suit
# 		@face = face
# 	end

# 	def print_card
# 		if @face.to_i < 11
# 			face = @face
# 		elsif @face == '11'
# 			face = 'J'
# 		elsif @face == '12'
# 			face = 'Q'
# 		elsif @face == '13'
# 			face = 'K'
# 		else
# 			face = 'A'
# 		end
# 		return face + " of " + @suit + " "
# 	end

# 	def image_name
# 		if @face.to_i < 11
# 			img = @face
# 		elsif @face == '11'
# 			img = 'J'
# 		elsif @face == '12'
# 			img = 'Q'
# 		elsif @face == '13'
# 			img = 'K'
# 		else
# 			img = 'A'
# 		end
# 		return img + @suit[0].upcase
# 	end
# end

# class Player
# 	attr_reader	:seat_pos, :hand, :pile
# 	def initialize(seat_pos)
# 		@seat_pos = seat_pos
# 		@hand = []
# 		@pile = []
# 	end

# 	def lead_card(two_played)
# 		if two_played == false
# 			card = @hand.select { |card| card.suit == 'clubs' && card.face == '2'}[0]
# 		else
# 			card = @hand.min {|a,b| a.face.to_i <=> b.face.to_i }
# 		end
# 		@hand.delete(card)
# 		puts "Player #{@seat_pos}: played  #{card.print_card()}"
# 		return card
# 	end

# 	def play_card(lead)
# 		suit = lead.suit
# 		suited_cards = @hand.select { |card| card.suit == suit }
# 		if suited_cards.size > 0
# 			card = suited_cards.min {|a,b| a.face.to_i <=> b.face.to_i }
# 		else
# 			card = @hand.max {|a,b| a.face.to_i <=> b.face.to_i }
# 		end
# 		@hand.delete(card)
# 		puts "Player #{@seat_pos}: played  #{card.print_card()}"
# 		return card
# 	end
# end

# class ScoreBoard
# 	attr_reader :scores

# 	def initialize(players)
# 		@scores = [0, 0, 0, 0]
# 	end

# 	def update_scoreboard(round_scores)
# 		puts "---Overall Scoreboard---"
# 		round_scores.each do |s|
# 			@scores[s["player"]] += s["points"]
# 		end
# 		@scores.each_with_index do |s, i|
# 			puts "Player #{i}: has #{s} points"
# 		end
# 	end
# end

# class Hearts
# 	attr_reader :players, :scoreboard
# 	def initialize
# 		puts "Starting Hearts Game"
# 		@players = [Player.new(0), Player.new(1), Player.new(2), Player.new(3)]
# 		@scoreboard = ScoreBoard.new(@players)
# 		#while @scoreboard.scores.max < 75
# 			round = Round.new(@players)
# 			#@scoreboard.update_scoreboard(round.round_scores)
# 		#end
# 	end
# end

# class Round
# 	attr_reader :round_scores
# 	def initialize(players)
# 		deal_cards(players)
# 		@round_scores = play_round(players)
# 	end

# 	def deal_cards(players)
# 		deck = Deck.new
# 		while deck.cards.size > 0
# 			players.each do |p|
# 				p.hand << deck.cards.pop
# 			end
# 		end
# 	end

# 	def play_round(players)
# 		start_player = who_has_the_two(players)
# 		turn = players.rotate(start_player)
# 		two_played = false;
# 		lead = nil;
# 		#for r in 0..12
# 			lead = turn[0].lead_card(two_played)
# 			if two_played == false
# 				if lead.suit == 'clubs' && lead.face == '2'
# 					two_played = true
# 				end
# 			end
# 			trick = [{"player" => turn[0].seat_pos, "card" => lead}]
# 			turn = turn.rotate(1)
# 			for t in 0..2
# 				trick << {"player" => turn[0].seat_pos, "card" => turn[0].play_card(lead)}
# 				turn = turn.rotate(1)
# 			end
# 			turn = players.rotate(determine_trick_winner(lead, trick))
# 			players[turn[0].seat_pos].pile << trick
# 			puts "---"
# 		#end
# 		scores = calculate_points(players)
# 		return scores
# 	end

# 	def calculate_points(players)
# 		scores = Array.new
# 		players.each do |p|
# 			points = 0
# 			p.pile.each do |t|
# 				t.each do |c|
# 					if c["card"].suit == 'hearts'
# 						points += 1
# 					elsif c["card"].face == '12' && c["card"].suit == 'spades'
# 						points += 13
# 					end
# 				end
# 			end
# 			scores << {'player' => p.seat_pos, 'points' => points}
# 			p.pile.clear
# 			puts "Player #{p.seat_pos}: Recieved #{points} points"
# 		end
# 		return scores
# 	end

# 	def determine_trick_winner(lead, trick)
# 		suit = lead.suit
# 		suited_cards = trick.select { |c| c["card"].suit == suit }
# 		winner = suited_cards.max {|a,b| a["card"].face.to_i <=> b["card"].face.to_i }
# 		puts "Winner is #{winner['player']}"
# 		return winner["player"]
# 	end

# 	def who_has_the_two(players)
# 		players.each do |p|
# 			p.hand.each do |card|
# 				if card.face == '2' && card.suit == 'clubs'
# 					return p.seat_pos
# 				end
# 			end
# 		end
# 	end
# end
class CashOut < ApplicationRecord
  belongs_to :p_game
  validates :name, presence: true
  validates :buyin, presence: true
  validates :buyout, presence: true
  validate :validate_players 

  def validate_players
	player = PokerPlayer.find_by name: self.name
      if player == nil
        raise "Player " + self.name + " does not exist. Please add player first."
      end
  end

end
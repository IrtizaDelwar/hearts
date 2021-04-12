class PokerPlayer < ApplicationRecord
  validates :name, format: { with: /\A[a-zA-Z0-9]+\Z/ }
  validates :name, presence: true
  validates :name, uniqueness: true
  validates_uniqueness_of :name, :case_sensitive => false
  validates :elo, presence: true
  validates :buyins, presence: true
  validates :cashout, presence: true
  validates :games, presence: true
end
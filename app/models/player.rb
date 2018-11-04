class Player < ApplicationRecord
  validates :name, presence: true
  validates :elo, presence: true
  validates :wins, presence: true
  validates :losses, presence: true
end

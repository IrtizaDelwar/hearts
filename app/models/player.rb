class Player < ApplicationRecord
  validates :name, format: { with: /\A[a-zA-Z0-9]+\Z/ }
  validates :name, presence: true
  validates :name, uniqueness: true
  validates_uniqueness_of :name, :case_sensitive => false
  validates :elo, presence: true
  validates :wins, presence: true
  validates :losses, presence: true
end

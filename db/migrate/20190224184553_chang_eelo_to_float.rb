class ChangEeloToFloat < ActiveRecord::Migration[5.2]
  def change
	change_column :poker_players, :elo, :float
  end
end

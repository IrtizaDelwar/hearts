class AddIdToGames < ActiveRecord::Migration[5.2]
  def change
	add_column :games, :game_id, :integer, auto_increment: true
  end
end

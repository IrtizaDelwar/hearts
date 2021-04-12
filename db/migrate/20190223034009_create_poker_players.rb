class CreatePokerPlayers < ActiveRecord::Migration[5.2]
  def change
    create_table :poker_players do |t|
	t.string :name
	t.integer :elo
	t.integer :buyins
	t.integer :cashout
	t.integer :games
	t.timestamps
    end
  end
end

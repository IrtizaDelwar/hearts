class CreateCashOut < ActiveRecord::Migration[5.2]
  def change
    create_table :cash_outs do |t|
	t.integer :p_game_id
	t.string :name
	t.integer :buyin
	t.integer :buyout
    end
  end
end

class CreateGames < ActiveRecord::Migration[5.2]
  def change
    create_table :games do |t|
      t.string :winner
      t.string :losers
      t.timestamps
    end
  end
end

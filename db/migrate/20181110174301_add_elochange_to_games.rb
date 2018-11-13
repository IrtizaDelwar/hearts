class AddElochangeToGames < ActiveRecord::Migration[5.2]
  def change
    add_column :games, :elochange, :string
  end
end

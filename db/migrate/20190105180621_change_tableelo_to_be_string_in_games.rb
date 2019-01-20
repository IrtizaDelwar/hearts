class ChangeTableeloToBeStringInGames < ActiveRecord::Migration[5.2]
  def change
    change_column :games, :tableelo, :string
  end
end

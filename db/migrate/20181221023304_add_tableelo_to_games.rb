class AddTableeloToGames < ActiveRecord::Migration[5.2]
  def change
    add_column :games, :tableelo, :integer
  end
end

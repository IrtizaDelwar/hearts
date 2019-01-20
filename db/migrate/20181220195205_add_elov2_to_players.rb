class AddElov2ToPlayers < ActiveRecord::Migration[5.2]
  def change
    add_column :players, :elov2, :integer, :default => 1200
  end
end

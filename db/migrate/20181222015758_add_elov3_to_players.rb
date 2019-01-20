class AddElov3ToPlayers < ActiveRecord::Migration[5.2]
  def change
    add_column :players, :elov3, :integer, :default => 1200
  end
end

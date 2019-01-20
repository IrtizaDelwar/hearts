class Changeelov2ToFloat < ActiveRecord::Migration[5.2]
  def change
    change_column :players, :elov2, :float
  end
end

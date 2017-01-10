class ChangePriceFieldInRentingPhases < ActiveRecord::Migration[5.0]
  def up
    change_column :renting_phases, :price, :decimal, scale: 2, precision: 131072
  end

  def down
    change_column :renting_phases, :price, :decimal
  end
end

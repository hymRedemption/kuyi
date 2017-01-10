class ChangeUnitPriceAndTotalFieldInLineItems < ActiveRecord::Migration[5.0]
  def up
    change_column :line_items, :unit_price, :decimal, scale: 2, precision: 131072
    change_column :line_items, :total, :decimal, scale: 2, precision: 131072
  end

  def down
    change_column :line_items, :unit_price, :decimal
    change_column :line_items, :total, :decimal
  end
end

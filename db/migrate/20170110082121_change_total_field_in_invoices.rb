class ChangeTotalFieldInInvoices < ActiveRecord::Migration[5.0]
  def up
    change_column :invoices, :total, :decimal, scale: 2, precision: 131072
  end

  def down
    change_column :invoices, :total, :decimal
  end
end

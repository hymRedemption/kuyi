class RemoveInvoiceNumFromRentingPhases < ActiveRecord::Migration[5.0]
  def up
    remove_column :renting_phases, :invoice_num
  end

  def down
    add_column :renting_phases, :invoice_num, :integer
  end
end

class AddInvoiceNumToRentingPhases < ActiveRecord::Migration[5.0]
  def change
    add_column :renting_phases, :invoice_num, :integer
  end
end

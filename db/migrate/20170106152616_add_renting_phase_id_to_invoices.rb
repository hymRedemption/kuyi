class AddRentingPhaseIdToInvoices < ActiveRecord::Migration[5.0]
  def change
    add_reference :invoices, :renting_phase, foreign_key: true
  end
end

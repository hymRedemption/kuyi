class CreateInvoices < ActiveRecord::Migration[5.0]
  def change
    create_table :invoices do |t|
      t.date :start_date
      t.date :end_date
      t.date :due_date
      t.decimal :total

      t.timestamps
    end
  end
end

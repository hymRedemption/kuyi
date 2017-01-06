class CreateLineItems < ActiveRecord::Migration[5.0]
  def change
    create_table :line_items do |t|
      t.date :start_date
      t.date :end_date
      t.decimal :unit_price
      t.integer :units
      t.decimal :total
      t.references :invoice, foreign_key: true

      t.timestamps
    end
  end
end

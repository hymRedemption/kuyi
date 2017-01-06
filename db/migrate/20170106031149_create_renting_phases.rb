class CreateRentingPhases < ActiveRecord::Migration[5.0]
  def change
    create_table :renting_phases do |t|
      t.date :start_date
      t.date :end_date
      t.decimal :price
      t.integer :cycles
      t.references :contract, foreign_key: true

      t.timestamps
    end
  end
end

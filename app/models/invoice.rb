class Invoice < ApplicationRecord

  include DatePhase

  has_many :line_items, dependent: :destroy
  belongs_to :renting_phase

  validates :start_date, presence: true
  validates :end_date, presence: true
  validates :due_date, presence: true
  validates :total, presence: true

  after_create :generate_items

  def months_in_phase
    1
  end

  def generate_items
    @items ||= time_ranges_of_phases.map do |time_range|
      units, unit_price = item_price_info(time_range[:start_date], time_range[:end_date])
      item_params = {
        unit_price: unit_price,
        units: units,
        total: units * unit_price,
        invoice: self
      }.merge(time_range)
      LineItem.create(item_params)
    end
  end

  private

    def item_price_info(item_start_date, item_end_date)
      units = 1
      unit_price = renting_phase.price
      if !item_start_date.integral_months_to?(item_end_date)
        units = item_start_date.scattered_days_to(item_end_date)
        unit_price = renting_phase.price_per_day
      end
      [units, unit_price]
    end
end

class Invoice < ApplicationRecord

  has_many :line_items
  belongs_to :renting_phase

  validates :start_date, presence: true
  validates :end_date, presence: true
  validates :due_date, presence: true
  validates :total, presence: true

  #after_save :set_line_items

  def items_num
    integral_months = start_date.integral_months_to(end_date)
    if !start_date.integral_months_to?(end_date)
      integral_months = integral_months + 1
    end
    integral_months
  end

  def time_ranges_of_items
    start_date_of_range = start_date
    result = items_num.times.map do |i|
      end_date_of_range = start_date.integral_months_end_date_since(i + 1)
      time_range = {
        start_date: start_date_of_range,
        end_date: end_date_of_range
      }
      start_date_of_range = end_date_of_range.next_day
      time_range
    end
    result.last[:end_date] = end_date
    result
  end

  def generate_items
    time_ranges_of_items.map do |time_range|
      total = renting_phase.price
      item_start_date = time_range[:start_date]
      item_end_date = time_range[:end_date]
      units = 1
      unit_price = renting_phase.price
      if !item_start_date.integral_months_to?(item_end_date)
        units = item_start_date.scattered_days_to(item_end_date)
        unit_price = renting_phase.price_per_day
      end
      total = units * unit_price
      item_params = {
        start_date: item_start_date,
        end_date: item_end_date,
        unit_price: unit_price,
        units: units,
        total: total,
        invoice: self
      }
      LineItem.create(item_params)
    end
  end
end

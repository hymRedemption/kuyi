class Invoice < ApplicationRecord
  include DatePhase

  has_many :line_items
  belongs_to :renting_phase

  validates :start_date, presence: true
  validates :end_date, presence: true
  validates :due_date, presence: true
  validates :total, presence: true

  #after_save :set_line_items

  def items_num
    if monthlong?(start_date, end_date)
      months_between(start_date, end_date)
    else
      months_between(start_date, end_date) + 1
    end
  end

  def time_ranges_of_items
    start_date_of_range = start_date
    result = items_num.times.map do |i|
      end_date_of_range = monthlong_end_date_since(i + 1, start_date)
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
  end

  private

    def date_phase_unit
      1
    end

    def set_line_items
      price = renting_phase.price
      price_per_day = renting_phase.price_per_day

      date_phases.map.with_index do |date_phase, i|
        unit_price = price
        units = 1
        if (phase_num == i + 1) && !last_phase_completed?
          days_in_phase = date_phase[:end_date] - date_phase[:start_date] + 1
          unit_price = price_per_day
          units = days_in_phase
        end
        date_phase[:total] = unit_price * units
        date_phase[:units] = units
        date_phase[:unit_price] = unit_price
        self.line_items.create(date_phase)
      end
    end
end

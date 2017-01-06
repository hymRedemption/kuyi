class Invoice < ApplicationRecord
  has_many :line_items
  belongs_to :renting_phase

  validates :start_date, presence: true
  validates :end_date, presence: true
  validates :due_date, presence: true
  validates :total, presence: true

  after_save :set_line_items

  private

    def need_prev?(date)
      start_date.mday == date.mday
    end

    def loop_num
      months_between = (end_date.mjd - start_date.mjd) / 29 + 1
      num = (1..months_between).find{ |i| start_date.months_since(i) > end_date }
    end

    def set_line_items
      item_start_date = start_date
      loop_num.times.map do |i|
        item_end_date = item_start_date.next_month
        if need_prev?(item_end_date)
          item_end_date = item_end_date.prev_day
        end
        if beyond_date?(item_end_date)
          item_end_date = end_date
          unit_price = renting_phase.price_per_day
          units = end_date.mjd - item_start_date.mjd + 1
        else
          unit_price = renting_phase.price
          units = 1
        end
        result = self.line_items.create(total: total, units: units, unit_price: unit_price, start_date: item_start_date, end_date: item_end_date)
        item_start_date = item_end_date.next_day
        result
      end
    end

    def beyond_date?(date)
      date > end_date
    end
end

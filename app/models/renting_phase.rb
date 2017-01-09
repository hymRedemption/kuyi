class RentingPhase < ApplicationRecord

  include DatePhase

  belongs_to :contract

  validates :start_date, presence: true
  validates :end_date, presence: true
  validates :cycles, presence: true
  validates :cycles, numericality: { only_integer: true, greater_than: 0 }
  validates :price, presence: true
  validates :price, numericality: { greater_than_or_equal_to: 0 }
  validate :date_confirm

  def cycles_num
    if monthlong?(start_date, end_date)
      return (months_between(start_date, end_date).to_f / cycles).ceil
    else
      return ((months_between(start_date, end_date).to_f + 1 )/ cycles).ceil
    end
  end

  def time_ranges_of_cycles
    start_date_of_range = start_date
    result = cycles_num.times.map do |i|
      end_date_of_range = monthlong_end_date_since((i + 1) * cycles, start_date)
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

  def invoices
    time_ranges_of_cycles.map do |time_range|
      total = price * cycles
      due_date = middle_of_prev_month(time_range[:start_date])
      invoice_start_date = time_range[:start_date]
      invoice_end_date = time_range[:end_date]
      if !monthlong?(invoice_start_date, invoice_end_date)
        total = scattered_days_between(invoice_start_date, invoice_end_date) * price_per_day + months_between(invoice_start_date, invoice_end_date) * price
      end
      invoice_param = {
        total: total,
        start_date: invoice_start_date,
        end_date: invoice_end_date,
        due_date: due_date,
        renting_phase: self
      }
      Invoice.create!(invoice_param)
    end
  end

  def date_phase_unit
    self.cycles
  end

  def price_per_day
    price * 12 / 365
  end

  private

  def date_confirm
    if start_date >=  end_date
      errors.add(:date_invalid, "start_date can't be later than end_date")
    end
  end
end

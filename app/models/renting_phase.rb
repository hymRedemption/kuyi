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

  def months_in_phase
    cycles
  end

  def invoices
    time_ranges_of_phases.map do |time_range|
      total = price * cycles
      due_date = time_range[:start_date].middle_of_prev_month
      invoice_start_date = time_range[:start_date]
      invoice_end_date = time_range[:end_date]
      if !invoice_start_date.integral_months_to?(invoice_end_date)
        total = invoice_start_date.scattered_days_to(invoice_end_date) * price_per_day + invoice_start_date.integral_months_to(invoice_end_date) * price
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

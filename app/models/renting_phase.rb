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

  def generate_invoices
    time_ranges_of_phases.map do |time_range|
      total = total_price_of_phase(time_range[:start_date], time_range[:end_date])
      due_date = time_range[:start_date].middle_of_prev_month
      invoice_param = {
        total: total,
        due_date: due_date,
        renting_phase: self
      }.merge(time_range)
      Invoice.create!(invoice_param)
    end
  end

  def price_per_day
    price * 12 / 365
  end

  private

  def total_price_of_phase(phase_start_date, phase_end_date)
    total = price * months_in_phase
    if !phase_start_date.integral_months_to?(phase_end_date)
      total = phase_start_date.scattered_days_to(phase_end_date) * price_per_day + phase_start_date.integral_months_to(phase_end_date) * price
    end
    total
  end

  def date_confirm
    if start_date >=  end_date
      errors.add(:date_invalid, "start_date can't be later than end_date")
    end
  end
end

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

  def invoices
    date_phases.map.with_index do |date_phase, i|
      total = price * cycles
      if (phase_num == i + 1) && !last_phase_completed?
        date_phase_start = date_phase[:start_date]
        date_phase_end = date_phase[:end_date]
        total = piece_days * price_per_day + months_between_dates(date_phase_end, date_phase_start) * price
      end
      date_phase[:total] = total
      due_date = middle_of_prev_month(date_phase[:start_date])
      date_phase[:due_date] = due_date
      date_phase[:renting_phase] = self
      Invoice.create!(date_phase)
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

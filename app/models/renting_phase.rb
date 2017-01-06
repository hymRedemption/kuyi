class RentingPhase < ApplicationRecord
  belongs_to :contract

  validates :start_date, presence: true
  validates :end_date, presence: true
  validates :cycles, presence: true
  validates :cycles, numericality: { only_integer: true, greater_than: 0 }
  validates :price, presence: true
  validates :price, numericality: { greater_than_or_equal_to: 0 }
  validates :invoice_num, presence: true

  validate :date_confirm

  before_validation :set_invoice_num

  def invoices
    Invoice.create!(self.invoices_params)
  end

  def invoices_params
    invoice_start_date = start_date
    invoice_num.times.map do |i|
      months_later = (i + 1) * cycles
      invoice_end_date = start_date.months_since(months_later)
      if need_prev?(invoice_end_date)
        invoice_end_date = invoice_end_date.prev_day
      end
      invoice_total = calculate_total(invoice_start_date, invoice_end_date)

      invoice_end_date = end_date if beyond_date?(invoice_end_date)

      invoice_params = {
        start_date: invoice_start_date,
        due_date: middle_of_prev_month(invoice_start_date),
        end_date: invoice_end_date,
        total: invoice_total,
        renting_phase: self,
      }
      invoice_start_date = invoice_end_date.next_day
      invoice_params
    end
  end

  def beyond_date?(date)
    date > end_date
  end

  def price_per_day
    price * 12 / 365
  end

  def calculate_total(invoice_start_date, invoice_end_date)
    days= end_date.mjd - invoice_start_date.mjd + 1
    beyond_date?(invoice_end_date) ? (days * price_per_day) : price
  end

  def need_prev?(date)
    start_date.mday == date.mday
  end

  protected

  def date_confirm
    if start_date >=  end_date
      errors.add(:date_invalid, "start_date can't be later than end_date")
    end
  end

  private

  def middle_of_prev_month(date)
    date.prev_month.beginning_of_month.days_since(14)
  end

  def set_invoice_num
    months_between = (end_date.mjd - start_date.mjd) / 29 + 1
    num = (1..months_between).find{ |i| start_date.months_since(i * cycles) > end_date }
    self.invoice_num = num
  end
end

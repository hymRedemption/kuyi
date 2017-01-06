class RentingPhase < ApplicationRecord
  belongs_to :contract

  validates :start_date, presence: true
  validates :end_date, presence: true
  validates :cycles, presence: true
  validates :cycles, numericality: { only_integer: true, greater_than: 0 }
  validates :price, presence: true
  validates :price, numericality: { greater_than_or_equal_to: 0 }

  validate :date_confirm

  protected

    def date_confirm
      if start_date >  end_date
        errors.add(:date_invalid, "start_date can't be later than end_date")
      end
    end
end

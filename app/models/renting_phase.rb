class RentingPhase < ApplicationRecord
  belongs_to :contract

  validates :start_date, presence: true
  validates :end_date, presence: true
  validates :price, presence: true
  validates :cycles, presence: true
end

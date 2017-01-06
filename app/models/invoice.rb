class Invoice < ApplicationRecord
  has_many :line_items
  belongs_to :renting_phase

  validates :start_date, presence: true
  validates :end_date, presence: true
  validates :due_date, presence: true
  validates :total, presence: true
end

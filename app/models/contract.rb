class Contract < ApplicationRecord
  has_many :renting_phases

  validates :start_date, presence: true
  validates :end_date, presence: true
  validate :date_comfirm


  def self.generate_contract(options)
    start_date = options[:start_date]
    end_date = options[:end_date]
    renting_phases_param = options[:renting_phases]
    contract = self.create!(start_date: start_date, end_date: end_date)
    phase_start_date = start_date
    renting_phases_param.each do |renting_phase|
      phase_end_date = renting_phase[:end_date]
      raise TimeRangeError if phase_start_date > phase_end_date
      renting_phase[:start_date] = phase_start_date
      phase_start_date = renting_phase[:end_date].days_since(1)
    end
    contract.renting_phases.create!(renting_phases_param)

    return contract
  end

  private

  def date_comfirm
    if start_date >  end_date
      errors.add(:date_invalid, "start_date can't be later than end_date")
    end
  end

  class TimeRangeError < ArgumentError; end
end

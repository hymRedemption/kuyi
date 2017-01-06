class Contract < ApplicationRecord
  validates :start_date, presence: true
  validates :end_date, presence: true

  has_many :renting_phases

  def self.generate_contract(options)
    start_date = options[:start_date]
    end_date = options[:end_date]
    due_date = options[:due_date]
    phase_num = options.fetch(:phase_num, 1)
    contract = self.create(start_date: start_date, end_date: end_date)
    phase_num.times do
      contract.renting_phases.create(start_date: start_date, end_date: end_date)
    end

    return contract
  end

end

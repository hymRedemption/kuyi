class Contract < ApplicationRecord
  has_many :renting_phases

  validates :start_date, presence: true
  validates :end_date, presence: true
  validate :date_confirm

  class << self

    def generate_contract(options)
      opts = options.dup
      start_date = opts[:start_date]
      end_date = opts[:end_date]
      contract = self.create!(start_date: start_date, end_date: end_date)
      generate_phases(contract, opts)

      return contract
    end

    private

      def generate_phases(contract, options)
        start_date = options[:start_date]
        phases_params = options[:renting_phases]
        set_phases_time!(start_date, phases_params)
        contract.renting_phases.create!(phases_params)
      end

      def set_phases_time!(start_date, params_arry)
        next_phase_start_date = start_date
        params_arry.each do |params|
          params[:start_date] = next_phase_start_date
          phase_end_date = params[:end_date]
          if !(next_phase_start_date && phase_end_date) || (next_phase_start_date > phase_end_date)
            raise TimeRangeError
          end
          next_phase_start_date = phase_end_date.days_since(1)
        end
      end
  end

  def generate_invoices
    []
  end

  private

    def date_confirm
      if start_date >  end_date
        errors.add(:date_invalid, "start_date can't be later than end_date")
      end
    end

    class TimeRangeError < ArgumentError; end
end

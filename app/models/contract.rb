class Contract < ApplicationRecord
  has_many :renting_phases

  validates :start_date, presence: true
  validates :end_date, presence: true
  validate :date_confirm

  class << self

    # @param options [Hash] Attrs for setup.
    # == Example
    #   params = {
    #    start_date : Date.new(1999, 1,1)
    #    end_date: Date,new(1999, 12, 12)
    #    renting_phases: [
    #     {
    #      end_date: Date.new(1999, 2, 3),
    #      price: 199,
    #      cycles: 1
    #     },
    #     {
    #      end_date: Date.new(1999, 4, 5),
    #      cycles: 2,
    #      price: 2,
    #     },
    #     {
    #      end_date: Date.new(1999, 12, 12),
    #      price:2,
    #      cycles: 1
    #     }
    #    ]
    #   }
    #   Controct.generate_contract(params)
    def generate_contract(options)
      Contract.transaction do
        opts = options.dup
        start_date = opts[:start_date]
        end_date = opts[:end_date]
        contract = self.create!(start_date: start_date, end_date: end_date)
        generate_phases(contract, opts)
        return contract
      end
    end

    private

      def generate_phases(contract, options)
        Contract.transaction do
          start_date = options[:start_date]
          phases_params = options[:renting_phases]
          set_phases_time!(start_date, phases_params)
          contract.renting_phases.create!(phases_params)
        end
      end

      def set_phases_time!(start_date, params_arry)
        next_phase_start_date = start_date
        params_arry.each do |params|
          params[:start_date] = next_phase_start_date
          phase_end_date = params[:end_date]
          if !(next_phase_start_date && phase_end_date) || (next_phase_start_date > phase_end_date)
            raise Errors::TimeRangeError
          end
          next_phase_start_date = phase_end_date.days_since(1)
        end
      end
  end

  def generate_invoices
    renting_phases.map(&:invoices).flatten
  end

  private

    def date_confirm
      if start_date >=  end_date
        errors.add(:date_invalid, "start_date can't be later than end_date")
      end
    end
end

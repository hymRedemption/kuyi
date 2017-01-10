class Contract < ApplicationRecord
  has_many :renting_phases

  validates :start_date, presence: true
  validates :end_date, presence: true
  validate :date_confirm

  class << self

    def generate_contract(options)
      Contract.transaction do
        opts = normalize_param(options)
        contract = self.create!(start_date: opts[:start_date], end_date: opts[:end_date])
        contract.renting_phases.create!(opts[:renting_phases])
        contract
      end
    end

    private

      def normalize_param(options)
        opts = options.dup
        normalize_date(opts)
        complete_phase_date(opts)
        check_date_logical(opts)
        opts
      end

      def normalize_date(options)
        options[:start_date] = date_transform(options[:start_date])
        options[:end_date] = date_transform(options[:end_date])
        phases = options[:renting_phases]
        phases.first[:start_date] ||= options[:start_date]
        nomalize_phases_date!(phases)
      end

      def nomalize_phases_date!(phase_params_array)
        phase_params_array.each do |phase_params|
          phase_params[:start_date] = date_transform(phase_params[:start_date]) if phase_params[:start_date]
          phase_params[:end_date] = date_transform(phase_params[:end_date]) if phase_params[:end_date]
        end
      end

      def date_transform(date)
        return date if date.is_a?(Date)
        begin
          return date.to_date if date.respond_to?(:to_date)
        rescue ArgumentError
          raise Errors::InvalidDate
        end
        raise Errors::InvalidDate
      end

      def complete_phase_date(options)
        contract_end_date = options[:end_date]
        phases = options[:renting_phases]
        check_meeting_rules(phases)
        phases.each_with_index  do |phase, i|
          next_phase = phases[i + 1]
          phase_end_date = next_phase ? next_phase[:start_date].prev_day : contract_end_date
          phase[:end_date] ||= phase_end_date
        end
      end

      def check_meeting_rules(phases)
        raise Errors::NotMeetingRules if phases.any? { |phase| phase[:start_date].nil? }
      end

      def check_date_logical(options)
        unless date_consistent_with_contract?(options)
          raise Errors::InvalidDateRange
        end

        unless date_contiguous?(options[:renting_phases])
          raise Errors::InvalidDateRange
        end
      end

      def date_consistent_with_contract?(options)
        contract_start_date = options[:start_date]
        contract_end_date = options[:end_date]
        phases = options[:renting_phases]

        return false if phases.first[:start_date] != contract_start_date
        return false if phases.last[:end_date] != contract_end_date
        true
      end

      def date_contiguous?(phases)
        result = true
        phases.each_with_index do |phase, i|
          next_phase = phases[i + 1]
          if next_phase
            if phase[:end_date].next_day != next_phase[:start_date]
              result = false
            end
          end
        end
        result
      end
  end

  def generate_invoices
    renting_phases.map(&:generate_invoices).flatten
  end

  private

  def date_confirm
    if start_date >=  end_date
      errors.add(:date_invalid, "start_date can't be later than end_date")
    end
  end
end

require 'active_support/concern'

module DatePhase
  extend ActiveSupport::Concern

  def phase_num
    if start_date.integral_months_to?(end_date)
      (start_date.integral_months_to(end_date).to_f / months_in_phase).ceil
    else
      ((start_date.integral_months_to(end_date).to_f + 1 ) / months_in_phase).ceil
    end
  end

  def time_ranges_of_phases
    start_date_of_range = start_date
    result = phase_num.times.map do |i|
      end_date_of_range = start_date.integral_months_end_date_since((i + 1) * months_in_phase)
      time_range = {
        start_date: start_date_of_range,
        end_date: end_date_of_range
      }
      start_date_of_range = end_date_of_range.next_day
      time_range
    end
    result.last[:end_date] = end_date
    result
  end
end

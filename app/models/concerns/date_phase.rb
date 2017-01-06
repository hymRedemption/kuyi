require 'active_support/concern'

module DatePhase
  extend ActiveSupport::Concern

  def phase_num
    months_between = (end_date.mjd - start_date.mjd) / 29 + 1
    (1..months_between).find { |i| start_date.months_since( i * date_phase_unit) > end_date }
  end

  def date_phases
    result = phase_num.times.map do |i|
      start_time = start_date.months_since(i * date_phase_unit)
      end_time = start_date.months_since((i + 1) * date_phase_unit)
      end_time = end_time.prev_day if !days_not_enough?(end_time)
      end_time = end_date if end_time > end_date
      {start_date: start_time, end_date: end_time}
    end
    result.last[:end_date] = end_date unless last_phase_completed?
    result
  end

  def last_phase_completed?
    predict_end_date = start_date.months_since(phase_num * date_phase_unit).prev_day
    (predict_end_date == end_date) ? true : days_not_enough?(end_date)
  end

  def days_not_enough?(date)
    days_num = date.mday
    (start_date.mday > days_num) && (date.end_of_month.mday == days_num)
  end
end

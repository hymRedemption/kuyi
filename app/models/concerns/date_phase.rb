require 'active_support/concern'

module DatePhase
  extend ActiveSupport::Concern

  def phase_num
    months_between = (end_date.mjd - start_date.mjd) / 29 + 1
    result = (1..months_between).find do |i|
      start_date.months_since( i * date_phase_unit) > end_date
    end
    if start_date.mday > days_of_month(end_date)
      result = start_date.mday > end_date.mday ? result - 1 : result
    end
    result
  end

  def date_phases
    start_time = start_date
    result = phase_num.times.map do |i|
      end_time = start_time.months_since(date_phase_unit)
      end_time = end_time.prev_day if !days_not_enough?(end_time)
      end_time = end_date if end_time > end_date
      relt = {start_date: start_time, end_date: end_time}
      start_time = end_time.next_day
      relt
    end
    result.last[:end_date] = end_date unless last_phase_completed?
    result
  end

  def middle_of_prev_month(date)
    date.prev_month.beginning_of_month.days_since(14)
  end

  def last_phase_completed?
    predict_end_date = start_date.months_since(phase_num * date_phase_unit).prev_day
    return false if !same_month?(predict_end_date, end_date)
    (predict_end_date == end_date) ? true : days_not_enough?(end_date)
  end

  def days_of_month(date)
    date.end_of_month.mday
  end

  def months_between_dates(date1, date2)
    if same_month?(date1, date2)
      days_between =  (date1.mday - date2.mday).abs + 1
      return days_between == days_of_month(date1) ? 1 : 0
    end

    num = date1.year * 12 + date1.month - date2.year * 12 - date2.month
    sign = 1
    if num < 0
      date1, date2 = date2, date1
      sign = - 1
    end

    if date1.mday > days_of_month(date2)
      date1.mday >= date2.mday ? num : num -1
    else
      if date1.mday - 1 <= date2.mday
        return num * sign
      else
        return (num - 1) * sign
      end
    end
  end

  def months_in_phases
    return phase_num * date_phase_unit if last_phase_completed?
    last_date_phase = date_phases.last
    (phase_num - 1) * date_phase_unit + months_between_dates(last_date_phase[:end_date], last_date_phase[:start_date])
  end

  def piece_days
    end_date.mjd - start_date.months_since(months_in_phases).prev_day.mjd + 1
  end

  def same_month?(date1, date2)
    date1.year == date2.year && date1.month == date2.month
  end

  def days_not_enough?(date)
    days_num = date.mday
    (start_date.mday > days_num) && (date.end_of_month.mday == days_num)
  end
end

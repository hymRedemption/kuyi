require 'active_support/concern'

module DatePhase
  extend ActiveSupport::Concern

  def same_month?(date1, date2)
    date1.year == date2.year && date1.month == date2.month
  end

  def months_between(smaller_date, bigger_date)
    sign = 1
    if smaller_date > bigger_date
      smaller_date, bigger_date = bigger_date, smaller_date
      sign = -1
    end

    months_num = absolut_months_between(smaller_date, bigger_date)

    if same_month?(smaller_date, bigger_date)
      return sign * 1 if monthlong?(smaller_date, bigger_date)
    else
      return sign * (months_num - 1) if !monthlong?(smaller_date, bigger_date)
    end

    sign * months_num
  end

  def enough_days?(smaller_date, bigger_date)
    days = days_in_this_month(bigger_date)
    smaller_date.mday > days
  end

  def days_in_this_month(date)
    date.end_of_month.mday
  end

  def end_of_month?(date)
    date == date.end_of_month
  end

  def beginning_of_month?(date)
    date == date.beginning_of_month
  end

  private

    def monthlong?(smaller_date, bigger_date)
      if same_month?(smaller_date, bigger_date)
        monthlong_in_same_month?(smaller_date, bigger_date)
      else
        monthlong_in_different_month?(smaller_date, bigger_date)
      end
    end

    def monthlong_in_different_month?(smaller_date, bigger_date)
      months_num = absolut_months_between(smaller_date, bigger_date)
      if enough_days?(smaller_date, bigger_date)
        return false if !end_of_month?(bigger_date)
      else
        return false if smaller_date.months_since(months_num).prev_day > bigger_date
      end
      true
    end

    def monthlong_in_same_month?(smaller_date, bigger_date)
      return false unless end_of_month?(bigger_date) && beginning_of_month?(smaller_date)
      true
    end

    def absolut_months_between(smaller_date, bigger_date)
      bigger_date.year * 12 + bigger_date.month - smaller_date.year * 12 - smaller_date.month
    end
end

=begin
  def phase_num
    months_between = (end_date.mjd - start_date.mjd) / 29 + 1
    result = (1..months_between).find do |i|
      start_date.months_since( i * date_phase_unit) > end_date
    end
    if start_date.mday > days_of_month(end_date)
      result = start_date.months_since(result).mday == end_date.mday ? result - 1 : result
    end
    result
  end

  def end_of_month?(date)
    date.mday == date.end_of_month.mday
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

  def months_between_dates(bigger_date, smaller_date)
    if same_month?(bigger_date, smaller_date)
      days_between =  (bigger_date.mday - smaller_date.mday).abs + 1
      return days_between == days_of_month(bigger_date) ? 1 : 0
    end
    num = bigger_date.year * 12 + bigger_date.month - smaller_date.year * 12 - smaller_date.month
    sign = 1
    if num < 0
      bigger_date, smaller_date = smaller_date, bigger_date
      sign = - 1
    end

    if smaller_date.mday > days_of_month(bigger_date)
      smaller_date.mday >= bigger_date.mday ? num : num - 1
    else
      if smaller_date.mday - 1 <= bigger_date.mday
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


  def days_not_enough?(date)
    days_num = date.mday
    (start_date.mday > days_num) && (date.end_of_month.mday == days_num)
  end
=end

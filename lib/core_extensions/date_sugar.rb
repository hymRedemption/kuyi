module CoreExtensions
  module DateSugar
    def same_month?(date)
      self.year == date.year && self.month == date.month
    end

    def beginning_of_month?
      self == self.beginning_of_month
    end

    def end_of_month?
      self == self.end_of_month
    end

    def months_diff_to(date)
      date.year * 12 + date.month - self.year * 12 - self.month
    end

    def enough_days_of_this_month?(num)
      self.days_in_this_month >= num
    end

    def days_in_this_month
      self.end_of_month.mday
    end

    def integral_months_end_date_since(num)
      predict_end_date = self.months_since(num)
       if !self.integral_months_to?(predict_end_date)
         predict_end_date = predict_end_date.prev_day
       end
      predict_end_date
    end

    def scattered_days_to(date)
      sign, smaller_date, bigger_date = *order_with(date)
      return 0 if smaller_date.integral_months_to?(bigger_date)
      integral_months = smaller_date.integral_months_to(bigger_date)

      first_scattered_date = smaller_date.months_since(integral_months)
      if smaller_date.integral_months_to?(first_scattered_date)
        first_scattered_date = first_scattered_date.next_day
      end
      (bigger_date - first_scattered_date + 1).to_i * sign
    end

    def integral_months_to?(date)
      _, smaller_date, bigger_date = *order_with(date)

      return true if smaller_date.beginning_of_month? && date.end_of_month?
      integral_in_different_months?(smaller_date, bigger_date)
    end

    def integral_months_to(date)
      sign, smaller_date, bigger_date = *order_with(date)

      months_diff = smaller_date.months_diff_to(bigger_date)

      if smaller_date.beginning_of_month? && bigger_date.end_of_month?
        return sign * (months_diff + 1)
      end

      if smaller_than_months_diff?(smaller_date, bigger_date)
        return sign * (months_diff - 1)
      end

      sign * months_diff
    end

    def middle_of_prev_month
      self.prev_month.beginning_of_month.days_since(14)
    end

    private

      def integral_in_different_months?(smaller_date, bigger_date)
        return false if smaller_date.same_month?(bigger_date)
        days = smaller_date.mday
        if !bigger_date.enough_days_of_this_month?(days)
          return false if !bigger_date.end_of_month?
        else
          months_diff = smaller_date.months_diff_to(bigger_date)
          return false if smaller_date.months_since(months_diff).prev_day != bigger_date
        end
        true
      end

      def smaller_than_months_diff?(smaller_date, bigger_date)
        !smaller_date.same_month?(bigger_date) &&
          !smaller_date.integral_months_to?(bigger_date) &&
          smaller_date.mday > bigger_date.mday
      end

      def order_with(date)
        smaller_date , bigger_date = self, date
        sign = 1
        if smaller_date > bigger_date
          sign = -1
          smaller_date, bigger_date = bigger_date, smaller_date
        end
        [sign, smaller_date, bigger_date]
      end
  end
end

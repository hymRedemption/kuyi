require 'rails_helper'

RSpec.describe CoreExtensions::DateSugar do
  let(:date) { Date.new(2000, 1, 2) }
  context '#same_month?' do
    it 'returns true if dates in same month' do
      date2 = Date.new(2000, 1, 20)
      expect(date.same_month?(date2)).to eq(true)
    end

    it 'returns false if dates not in the same month' do
      date2 = Date.new(2000, 2, 20)
      expect(date.same_month?(date2)).to eq(false)
    end
  end

  context '#middle_of_prev_month' do
    it 'returns middle date of prev month not in a year' do
      expect(date.middle_of_prev_month).to eq(Date.new(1999, 12, 15))
    end

    it 'returns middle date of prev month in a year' do
      expect(Date.new(2000, 2, 2).middle_of_prev_month).to eq(Date.new(2000, 1, 15))
    end
  end

  context '#beginning_of_month?' do
    it 'returns true if date is beginning of month' do
      expect(Date.new(1, 1, 1).beginning_of_month?).to eq(true)
    end

    it 'returns false if date is not beginning of month' do
      expect(date.beginning_of_month?).to eq(false)
    end
  end

  context '#days_in_this_month' do
    it 'returns the days num of this month' do
      expect(Date.new(2000, 1, 1).days_in_this_month).to eq(31)
      expect(Date.new(2000, 2, 2).days_in_this_month).to eq(29)
      expect(Date.new(2000, 4, 6).days_in_this_month).to eq(30)
    end
  end

  context '#end_of_month' do
    it 'returns true if date is the end of month' do
      expect(Date.new(2000, 2, 29).end_of_month?).to eq(true)
    end

    it 'returns false if date is not the end of month' do
      expect(date.end_of_month?).to eq(false)
    end
  end

  context '#months_diff_to' do
    it 'returns the month diff of the dates' do
      expect(date.months_diff_to(Date.new(2000, 2, 3))).to eq(1)
    end

    it 'returns negative if date is smaller than this date' do
      expect(date.months_diff_to(Date.new(1999, 10, 2))).to eq(-3)
    end
  end

  context '#enough_days_of_this_month?' do
    it 'returns ture if days is enough' do
      expect(Date.new(2000, 1, 6).enough_days_of_this_month?(24)).to eq(true)
    end

    it 'returns false if days is not enough' do
      expect(Date.new(2000, 2, 6).enough_days_of_this_month?(30)).to eq(false)
    end
  end

  context '#integral_months_to?' do
    context 'same month' do
      it 'returns true if dates at the beginning and end of month' do
        smaller_date = Date.new(2000, 1, 1)
        bigger_date = Date.new(2000, 1, 31)
        expect(smaller_date.integral_months_to?(bigger_date)).to eq(true)
      end

      it 'returns false if dates not at begin and the end' do
        smaller_date = Date.new(2000, 1, 1)
        bigger_date = Date.new(2000, 1, 18)
        expect(smaller_date.integral_months_to?(bigger_date)).to eq(false)
      end
    end

    context 'different month' do
      it 'returns true if dates at the beginning and end of month' do
        smaller_date = Date.new(2000, 1, 1)
        bigger_date = Date.new(2000, 4, 30)
        expect(smaller_date.integral_months_to?(bigger_date)).to eq(true)
      end

      it 'returns true if days in bigger date month is not enough and bigger date is at the end' do
        smaller_date = Date.new(2000, 1, 30)
        bigger_date = Date.new(2000, 2, 29)
        expect(smaller_date.integral_months_to?(bigger_date)).to eq(true)
      end

      it 'returns true if days in bigger date month is enough and bigger date days equal smaller date days' do
        smaller_date = Date.new(2000, 1, 15)
        bigger_date = Date.new(2000, 2, 14)
        expect(smaller_date.integral_months_to?(bigger_date)).to eq(true)
      end
    end
  end

  context '#integral_months_to' do
    context 'bigger than months diff' do
      it 'returns value that 1 bigger than months diff' do
        smaller_date = Date.new(1999, 12, 1)
        bigger_date = Date.new(2000, 2, 29)
        expect(smaller_date.integral_months_to(bigger_date)).to eq(3)
      end
    end

    context 'smaller than months diff' do
      it 'returns value that 1 smaller than months diff if days between less than a month' do
        smaller_date = Date.new(2000, 1, 16)
        bigger_date = Date.new(2000, 3, 13)
        expect(smaller_date.integral_months_to(bigger_date)).to eq(1)
      end
    end

    context 'equal to months diff' do
      it 'returns 0 if in the same month but not at the end and begin' do
        smaller_date = Date.new(2000, 1, 1)
        bigger_date = Date.new(2000, 1, 18)
        expect(smaller_date.integral_months_to(bigger_date)).to eq(0)
      end

      it 'equals to months diff if not at the begin and end but is monthlong' do
        smaller_date = Date.new(2000, 1, 17)
        bigger_date = Date.new(2000, 2, 16)
        expect(smaller_date.integral_months_to(bigger_date)).to eq(1)
      end

      it 'equals to month diff if not monthlong and at the begin and end but days in smaller date is bigger' do
        smaller_date = Date.new(2000, 1, 19)
        bigger_date = Date.new(2000, 4, 19)
        expect(smaller_date.integral_months_to(bigger_date)).to eq(3)
      end
    end
  end

  context '#scattered_days_to' do
    it 'retuns 0 if the dates between is monthlong' do
      smaller_date = Date.new(2000, 1, 31)
      bigger_date = Date.new(2000, 2, 29)
      num = smaller_date.scattered_days_to(bigger_date)
      expect(num).to eq(0)
    end

    it 'returns the scattered days num between dates that in a month' do
      smaller_date = Date.new(2000, 1, 10)
      bigger_date = Date.new(2000, 1, 29)
      num = smaller_date.scattered_days_to(bigger_date)
      expect(num).to eq(20)
    end

    it 'returns days num between dates that not in a month' do
      smaller_date = Date.new(2000, 1, 10)
      bigger_date = Date.new(2000, 2, 29)
      num = smaller_date.scattered_days_to(bigger_date)
      expect(num).to eq(20)
    end

    it 'returns negative num if date to is in the past' do
      smaller_date = Date.new(2000, 1, 10)
      bigger_date = Date.new(2000, 2, 29)
      num = bigger_date.scattered_days_to(smaller_date)
      expect(num).to eq(-20)
    end
  end

  context '#integral_months_end_date_since' do
    it 'returns right end date if days in predict month is not enough' do
      date = Date.new(2000, 1, 31).integral_months_end_date_since(1)
      expect(date).to eq(Date.new(2000, 2, 29))
    end

    it 'returns right end date if days in predict month is enough' do
      date = Date.new(2000, 1, 29).integral_months_end_date_since(1)
      expect(date).to eq(Date.new(2000, 2, 28))
    end
  end
end

require 'rails_helper'

RSpec.describe DatePhase do
  let(:klass) { Class.new }
  let(:include_klass) { klass.class_exec{ include DatePhase } }
  let(:instance) { include_klass.new }
  context '#months_between' do
    context 'in the same month' do
      it 'returns right num if begin at month first date and end at month end day' do
        smaller_date = Date.new(2000, 1, 1)
        bigger_date = Date.new(2000, 3, 31)
        num = instance.months_between(smaller_date, bigger_date)
        expect(num).to eq(3)
      end

      it 'returns right num for special' do
        smaller_date = Date.new(2000, 1, 31)
        bigger_date = Date.new(2000, 2, 29)
        num = instance.months_between(smaller_date, bigger_date)
        expect(num).to eq(1)
      end

      it 'returns right num if when is a month' do
        smaller_date = Date.new(2000, 1, 2)
        bigger_date = Date.new(2000, 1, 14)
        num = instance.months_between(smaller_date, bigger_date)
        expect(num).to eq(0)
      end

      it 'returns right num if when is not in a month' do
        smaller_date = Date.new(2000, 1, 2)
        bigger_date = Date.new(2000, 3, 14)
        num = instance.months_between(smaller_date, bigger_date)
        expect(num).to eq(2)
      end
    end

    context '#monthlong_end_date_since' do
      it 'returns right end date if days in predict month is not enough' do
        date = instance.monthlong_end_date_since(1, Date.new(2000, 1, 31))
        expect(date).to eq(Date.new(2000, 2, 29))
      end

      it 'returns right end date if days in predict month is enough' do
        date = instance.monthlong_end_date_since(1, Date.new(2000, 1, 29))
        expect(date).to eq(Date.new(2000, 2, 28))
      end
    end

    context 'in the different month' do
      it 'returns correct num when in different year' do
        smaller_date = Date.new(1999, 12, 30)
        bigger_date = Date.new(2000, 2, 29)
        num = instance.months_between(smaller_date, bigger_date)
        expect(num).to eq(2)
      end

      it 'returns correct num when the date month is enough for a date' do
        smaller_date = Date.new(2000, 1, 29)
        bigger_date = Date.new(2000, 2, 29)
        num = instance.months_between(smaller_date, bigger_date)
        expect(num).to eq(1)
      end

      it 'returns corrent num when the date is not enough' do
        smaller_date = Date.new(2000, 1, 30)
        bigger_date = Date.new(2000, 2, 28)
        num = instance.months_between(smaller_date, bigger_date)
        expect(num).to eq(0)
      end

      it 'returns correct num when middle date is specifal' do
        smaller_date = Date.new(2000, 1, 1)
        bigger_date = Date.new(2000, 3, 31)
        num = instance.months_between(smaller_date, bigger_date)
        expect(num).to eq(3)
      end
    end
  end

  context '#monthlong?' do
    context 'same month' do
      it 'returns true if days between dates is a whole month' do
        smaller_date = Date.new(2000, 1, 1)
        bigger_date = Date.new(2000, 1, 31)
        expect(instance.monthlong?(smaller_date, bigger_date)).to eq(true)
      end

      it 'returns false if days between is not enough' do
        smaller_date = Date.new(2000, 1, 1)
        bigger_date = Date.new(2000, 1, 3)
        expect(instance.monthlong?(smaller_date, bigger_date)).to eq(false)
      end
    end

    context 'different month' do
      it 'returns true if days between is whole month' do
        smaller_date = Date.new(1999, 12, 30)
        bigger_date = Date.new(2000, 2, 29)
        expect(instance.monthlong?(smaller_date, bigger_date)).to eq(true)
      end

      it 'returns false if days between is not enough' do
        smaller_date = Date.new(1999, 12, 30)
        bigger_date = Date.new(2000, 2, 28)
        expect(instance.monthlong?(smaller_date, bigger_date)).to eq(false)
      end
    end
  end

  context '#scattered_days_between' do
    it 'retuns 0 if the dates between is monthlong' do
      smaller_date = Date.new(2000, 1, 31)
      bigger_date = Date.new(2000, 2, 29)
      num = instance.scattered_days_between(smaller_date, bigger_date)
      expect(num).to eq(0)
    end

    it 'returns the scattered days num between dates that in a month' do
      smaller_date = Date.new(2000, 1, 10)
      bigger_date = Date.new(2000, 1, 29)
      num = instance.scattered_days_between(smaller_date, bigger_date)
      expect(num).to eq(20)
    end

    it 'returns days num between dates that not in a month' do
      smaller_date = Date.new(2000, 1, 10)
      bigger_date = Date.new(2000, 2, 29)
      num = instance.scattered_days_between(smaller_date, bigger_date)
      expect(num).to eq(20)
    end
  end

  context '#same_month?' do
    it 'returns true if it in the same month' do
      date1 = Date.new(2000, 1, 20)
      date2 = Date.new(2000, 1, 1)
      expect(instance.same_month?(date1, date2)).to eq(true)
    end

    it 'returns false if dates in different year' do
      date1 = Date.new(1999, 1, 1)
      date2 = Date.new(2000, 1, 1)
      expect(instance.same_month?(date1, date2)).to eq(false)
    end

    it 'returns false if dates in different month' do
      date1 = Date.new(1999, 2, 1)
      date2 = Date.new(1999, 1, 1)
      expect(instance.same_month?(date1, date2)).to eq(false)
    end
  end
end

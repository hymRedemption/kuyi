require 'rails_helper'

RSpec.describe DatePhase do
  let(:klass) { Class.new }
  let(:include_klass) { klass.class_exec{ include DatePhase } }
  let(:instance) { include_klass.new }
  context '#months_between' do
    context 'in the same month' do
      it 'returns 1 when is a month' do
        smaller_date = Date.new(2000, 1, 1)
        bigger_date = Date.new(2000, 1, 31)
        num = instance.months_between(smaller_date, bigger_date)
        expect(num).to eq(1)
      end

      it 'returns 0 when is not enough for a month' do
        smaller_date = Date.new(2000, 1, 1)
        bigger_date = Date.new(2000, 1, 29)
        num = instance.months_between(smaller_date, bigger_date)
        expect(num).to eq(0)
      end
    end

    context 'not in the different month' do
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

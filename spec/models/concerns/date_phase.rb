require 'rails_helper'

RSpec.describe DatePhase do
  let(:klass) { Class.new }
  let(:include_klass) { klass.class_exec{ include DatePhase } }
  let(:instance) { include_klass.new }
  context '#months_between_dates' do
    it 'returns 1 when is full month' do
      date1 = Date.new(2000, 1, 31)
      date2 = Date.new(2000, 1, 1)
      num  = instance.months_between_dates(date1, date2)
      expect(num).to eq(1)
    end

    it 'returns 1 if a month' do
      date1 = Date.new(2000, 2, 29)
      date2 = Date.new(2000, 2, 1)
      num  = instance.months_between_dates(date1, date2)
      expect(num).to eq(1)
    end

    it 'returns 1 if enough for a month' do
      date1 = Date.new(2000, 5,  9)
      date2 = Date.new(2000, 4, 10)
      num  = instance.months_between_dates(date1, date2)
      expect(num).to eq(1)
    end

    it 'returns 0 if not a month' do
      date1 = Date.new(2000, 4, 20)
      date2 = Date.new(2000, 3, 2)
      num  = instance.months_between_dates(date1, date2)
      expect(num).to eq(0)
    end
  end


end

require 'rails_helper'

RSpec.describe DatePhase do
  let(:instance) do
    Class.class_exec do
      attr_accessor :start_date, :end_date, :months_in_phase
      include DatePhase
    end
  end

  context '#time_ranges_of_phases' do
    context 'months in phase is 1' do
      before :each do
        instance.start_date = Date.new(1999, 12, 31)
        instance.end_date = Date.new(2000, 4, 2)
        instance.months_in_phase = 1
      end
      let(:result_of_time_ranges) do
        [
          {
            start_date: Date.new(1999, 12, 31),
            end_date: Date.new(2000, 1, 30)
          },
          {
            start_date: Date.new(2000, 1, 31),
            end_date: Date.new(2000, 2, 29)
          },
          {
            start_date: Date.new(2000, 3, 1),
            end_date: Date.new(2000, 3, 30)
          },
          {
            start_date: Date.new(2000, 3, 31),
            end_date: Date.new(2000, 4, 2)
          }
        ]
      end

      it 'returns time ranges with right size' do
        time_ranges = instance.time_ranges_of_phases
        expect(time_ranges.size).to eq(result_of_time_ranges.size)
      end

      it 'returns right time ranges' do
        time_ranges = instance.time_ranges_of_phases
        expect(time_ranges).to eq(result_of_time_ranges)
      end
    end

    context 'months in phase is more than 1' do
      before :each do
        instance.start_date = Date.new(1999, 12, 31)
        instance.end_date = Date.new(2000, 4, 2)
        instance.months_in_phase = 2
      end
      let(:result_of_time_ranges) do
        [
          {
            start_date: Date.new(1999, 12, 31),
            end_date: Date.new(2000, 2, 29)
          },
          {
            start_date: Date.new(2000, 3, 1),
            end_date: Date.new(2000, 4, 2)
          }
        ]
      end

      it 'returns time ranges with right size' do
        time_ranges = instance.time_ranges_of_phases
        expect(time_ranges.size).to eq(result_of_time_ranges.size)
      end

      it 'returns right time ranges' do
        time_ranges = instance.time_ranges_of_phases
        expect(time_ranges).to eq(result_of_time_ranges)
      end
    end
  end
end

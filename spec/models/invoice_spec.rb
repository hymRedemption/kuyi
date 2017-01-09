require 'rails_helper'

RSpec.describe Invoice, type: :model do
  let(:price) { 100.0 }
  let(:price_per_day) { price * 12 / 365 }
  let(:invoice_with_monthlong) do
    FactoryGirl.create(:invoice,
                       start_date: Date.new(2000, 1, 1),
                       end_date: Date.new(2000, 2, 29),
                       due_date: Date.new(1999, 12, 15),
                       total: price * 3)
  end
  let(:invoice_not_monthlong) do
    FactoryGirl.create(:invoice,
                       start_date: Date.new(1999, 12, 31),
                       end_date: Date.new(2000, 3, 12),
                       due_date: Date.new(1999, 11, 15),
                       total: price * 2 + price_per_day * 12)
  end

  context '#item_num' do
    it 'returns the correct items num when dates is monthlong' do
      expect(invoice_with_monthlong.items_num).to eq(2)
    end

    it 'returns the correct items num when dates is not monthlong' do
      expect(invoice_not_monthlong.items_num).to eq(3)
    end
  end

  context '#tiem_ranges_of_items' do
    it 'returns the correct ranges when dates is monthlong' do
      time_ranges = invoice_with_monthlong.time_ranges_of_items
      result_expect = [
        {
          start_date: Date.new(2000, 1, 1),
          end_date: Date.new(2000, 1, 31)
        },
        {
          start_date: Date.new(2000, 2, 1),
          end_date: Date.new(2000, 2, 29)
        }
      ]
      expect(time_ranges).to eq(result_expect)
    end

    it 'returns correct ranges when dates is not monthlong' do
      time_ranges = invoice_not_monthlong.time_ranges_of_items
      result_expect = [
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
          end_date: Date.new(2000, 3, 12)
        }
      ]
      expect(time_ranges).to eq(result_expect)
    end
  end
end

require 'rails_helper'

RSpec.describe Invoice, type: :model do
  let(:price) { 100.0 }
  let(:price_per_day) { price * 12 / 365 }
  let(:renting_phase) do
    FactoryGirl.create(:renting_phase,
                       price: price)
  end
  let(:invoice_with_monthlong) do
    FactoryGirl.create(:invoice,
                       start_date: Date.new(2000, 1, 1),
                       end_date: Date.new(2000, 2, 29),
                       due_date: Date.new(1999, 12, 15),
                       total: price * 3,
                       renting_phase: renting_phase)
  end
  let(:invoice_not_monthlong) do
    FactoryGirl.create(:invoice,
                       start_date: Date.new(1999, 12, 31),
                       end_date: Date.new(2000, 3, 12),
                       due_date: Date.new(1999, 11, 15),
                       total: price * 2 + price_per_day * 12,
                       renting_phase: renting_phase)
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

  context '#generate_items' do
    it 'returns right items when dates is monthlong' do
      items = invoice_with_monthlong.generate_items
      expect(items[0].start_date).to eq(Date.new(2000, 1, 1))
      expect(items[0].end_date).to eq(Date.new(2000, 1, 31))
      expect(items[0].unit_price).to eq(price)
      expect(items[0].units).to eq(1)
      expect(items[0].total).to eq(price)
      expect(items[1].start_date).to eq(Date.new(2000, 2,1))
      expect(items[1].end_date).to eq(Date.new(2000, 2, 29))
      expect(items[1].unit_price).to eq(price)
      expect(items[1].units).to eq(1)
      expect(items[1].total).to eq(price)
    end

    it 'returns right items when dates is not monthlong' do
      items = invoice_not_monthlong.generate_items
      expect(items[0].start_date).to eq(Date.new(1999, 12, 31))
      expect(items[0].end_date).to eq(Date.new(2000, 1, 30))
      expect(items[0].unit_price).to eq(price)
      expect(items[0].units).to eq(1)
      expect(items[0].total).to eq(price)
      expect(items[1].start_date).to eq(Date.new(2000, 1, 31))
      expect(items[1].end_date).to eq(Date.new(2000, 2, 29))
      expect(items[1].unit_price).to eq(price)
      expect(items[1].units).to eq(1)
      expect(items[1].total).to eq(price)
      expect(items[2].start_date).to eq(Date.new(2000, 3, 1))
      expect(items[2].end_date).to eq(Date.new(2000, 3, 12))
      expect(items[2].unit_price).to eq(price_per_day)
      expect(items[2].units).to eq(12)
      expect(items[2].total).to eq(price_per_day * 12)
    end
  end
end

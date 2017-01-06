require 'rails_helper'

RSpec.describe Invoice, type: :model do
  let(:renting_phase) do
    FactoryGirl.create(:renting_phase,
                       start_date: Date.new(1999, 12, 31),
                       end_date: Date.new(2000, 2, 15),
                       price: 30,
                       cycles: 2 )
  end
  let(:line_items) { renting_phase.invoices.first.line_items }

  it 'returns correct line_items is a month' do
    invoice = renting_phase.invoices.first
    expect(invoice.line_items.count).to eq(2)
  end

  it 'has correct time' do
    expect(line_items.order(:start_date).first.start_date).to eq(Date.new(1999, 12, 31))
    expect(line_items.order(:start_date).first.end_date).to eq(Date.new(2000, 1, 30))
    expect(line_items.order(:start_date).last.start_date).to eq(Date.new(2000, 1, 31))
    expect(line_items.order(:start_date).last.end_date).to eq(Date.new(2000, 2, 15))
  end

  it 'has correct price and units' do
    expect(line_items.order(:start_date).first.units).to eq(1)
    expect(line_items.order(:start_date).first.unit_price).to eq(renting_phase.price)
    expect(line_items.order(:start_date).last.units).to eq(16)
    expect(line_items.order(:start_date).last.unit_price.floor(3)).to eq(renting_phase.price_per_day.floor(3))
  end
end

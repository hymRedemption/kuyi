require 'rails_helper'

RSpec.describe RentingPhase, type: :model do
  context '#invoice_num' do
    let(:start_date) { Date.new(1999, 12, 10) }
    let(:end_date) { Date.new(2000, 3, 15) }
    let(:phase_params) do
      {
        start_date: start_date,
        end_date: end_date,
        cycles: 1
      }
    end

    it 'sets invoice_num correctly' do
      renting_phase = FactoryGirl.create(:renting_phase, phase_params)
      expect(renting_phase.invoice_num).to eq(4)
    end

    it 'sets invoice_num correctly when cycles is 3' do
      phase_params[:cycles] = 3
      renting_phase = FactoryGirl.create(:renting_phase, phase_params)
      expect(renting_phase.invoice_num).to eq(2)
    end
  end

  context '#invoices' do
    let(:start_date) { Date.new(1999, 12, 31) }
    let(:end_date) { Date.new(2000, 4, 15) }
    let(:phase_params) do
      {
        start_date: start_date,
        end_date: end_date,
        cycles: 1
      }
    end
    it 'returns same num invoices as invoice_num' do
      renting_phase = FactoryGirl.create(:renting_phase, phase_params)
      invoices = renting_phase.invoices
      expect(invoices.size).to eq(renting_phase.invoice_num)
    end

    it 'returns all correct invoices when has February' do
      renting_phase = FactoryGirl.create(:renting_phase, phase_params)
      invoices = renting_phase.invoices
      expect(invoices[0].start_date).to eq(start_date)
      expect(invoices[0].end_date).to eq(Date.new(2000, 1, 30))
      expect(invoices[1].start_date).to eq(Date.new(2000, 1, 31))
      expect(invoices[1].end_date).to eq(Date.new(2000, 2, 29))
      expect(invoices[2].start_date).to eq(Date.new(2000, 3, 1))
      expect(invoices[2].end_date).to eq(Date.new(2000, 3, 30))
      expect(invoices[3].start_date).to eq(Date.new(2000, 3, 31))
      expect(invoices[3].end_date).to eq(Date.new(2000, 4, 15))
    end

    it 'returns corrent invoices when start at end of month' do
      phase_params[:start_date] = Date.new(2000, 5, 31)
      phase_params[:end_date] = Date.new(2000, 7, 31)
      renting_phase = FactoryGirl.create(:renting_phase, phase_params)
      invoices = renting_phase.invoices
      expect(invoices[0].end_date).to eq(Date.new(2000, 6, 30))
      expect(invoices[1].start_date).to eq(Date.new(2000, 7, 1))
      expect(invoices[1].end_date).to eq(Date.new(2000, 7, 30))
    end

    it 'returns invoices with right price' do
      phase_params[:start_date] = Date.new(2000, 5, 31)
      phase_params[:end_date] = Date.new(2000, 7, 10)
      renting_phase = FactoryGirl.create(:renting_phase, phase_params)
      invoices = renting_phase.invoices
      price = renting_phase.price
      price_per_day = price * 12/ 365
      expect(invoices[0].total).to eq(price)
      expect(invoices[1].total).to eq(10 * price_per_day)
    end

    it 'returns invoices with right due_date' do
      phase_params[:start_date] = Date.new(2000, 5, 31)
      phase_params[:end_date] = Date.new(2000, 7, 10)
      renting_phase = FactoryGirl.create(:renting_phase, phase_params)
      invoices = renting_phase.invoices
      price = renting_phase.price
      expect(invoices[0].due_date).to eq(Date.new(2000, 4, 15))
      expect(invoices[1].due_date).to eq(Date.new(2000, 6, 15))
    end
  end
end

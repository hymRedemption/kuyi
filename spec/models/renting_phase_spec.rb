require 'rails_helper'

RSpec.describe RentingPhase, type: :model do
  context '#invoice_num' do

    it 'sets invoice_num correctly' do
      start_date = Date.new(1999, 12, 31)
      end_date = Date.new(2000, 1, 31)
      renting_phase = FactoryGirl.create(:renting_phase,
                                         start_date: start_date,
                                         end_date: end_date,
                                         cycles: 1 )
      expect(renting_phase.invoice_num).to eq(2)
    end

    it 'sets invoice_num correctly when set cycles 2' do
      start_date = Date.new(1999, 12, 30)
      end_date = Date.new(2000, 7, 31)
      renting_phase = FactoryGirl.create(:renting_phase,
                                         start_date: start_date,
                                         end_date: end_date,
                                         cycles: 2 )
      expect(renting_phase.invoice_num).to eq(4)
    end
  end

  context '#invoices' do
    context 'cycles 1' do
      let(:start_date) { Date.new(1999, 12, 31) }
      let(:end_date) { Date.new(2000, 1, 31) }
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

      it 'returns all correct invoices' do
        renting_phase = FactoryGirl.create(:renting_phase, phase_params)
        invoices = renting_phase.invoices
        expect(invoices[0].start_date).to eq(start_date)
        expect(invoices[0].end_date).to eq(Date.new(2000, 1, 30))
      end

      it 'returns invoices with right price' do
        phase_params[:end_date] = Date.new(2000, 1, 10)
        renting_phase = FactoryGirl.create(:renting_phase, phase_params)
        invoices = renting_phase.invoices
        price = renting_phase.price
        price_per_day = price * 12/ 365
        expect(invoices[0].total.floor(4)).to eq(11 * price_per_day.floor(4))
      end

      it 'returns invoices with right due_date' do
        renting_phase = FactoryGirl.create(:renting_phase, phase_params)
        invoices = renting_phase.invoices
        expect(invoices[0].due_date).to eq(Date.new(1999, 11, 15))
      end
    end

    context 'cycles 2' do
      let(:start_date) { Date.new(1999, 12, 31) }
      let(:end_date) { Date.new(2000, 3, 1) }
      let(:phase_params) do
        {
          start_date: start_date,
          end_date: end_date,
          cycles: 2
        }
      end

      it 'returns same num invoices as invoice_num' do
        renting_phase = FactoryGirl.create(:renting_phase, phase_params)
        invoices = renting_phase.invoices
        expect(invoices.size).to eq(renting_phase.invoice_num)
      end

      it 'returns all correct invoices' do
        renting_phase = FactoryGirl.create(:renting_phase, phase_params)
        invoices = renting_phase.invoices
        expect(invoices[0].start_date).to eq(start_date)
        expect(invoices[0].end_date).to eq(Date.new(2000, 2, 29))
        expect(invoices[1].start_date).to eq(Date.new(2000, 3, 1))
        expect(invoices[1].end_date).to eq(Date.new(2000, 3, 1))
      end
    end
  end
end

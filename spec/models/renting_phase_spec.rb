require 'rails_helper'

RSpec.describe RentingPhase, type: :model do
  context '#invoice_num' do
    it 'sets invoice_num correctly' do
      start_date = Date.new(1999, 12, 10)
      end_date = Date.new(2000, 3, 15)
      renting_phase = FactoryGirl.create(:renting_phase,
                                         start_date: start_date,
                                         end_date: end_date,
                                         cycles: 1)
      expect(renting_phase.invoice_num).to eq(4)
    end
  end
end

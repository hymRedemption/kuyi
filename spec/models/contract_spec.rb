require 'rails_helper'

RSpec.describe Contract, type: :model do
  context '.generate_contract' do
    let(:start_date) { Date.new(2000, 1, 10) }
    let(:end_date) { Date.new(2000, 10, 8) }
    it 'generates contract' do
      contract = Contract.generate_contract(start_date: start_date, end_date: end_date, price: 100)
      expect(contract.is_a?(Contract)).to eq(true)
    end

    it 'has same renting phases as we set' do
      phase_num = 2
      contract = Contract.generate_contract(start_date: start_date, end_date: end_date, price: 100, phase_num: phase_num)
      expect(contract.renting_phases.count).to eq(2)
    end

    it 'has one renting phase if we do not set phase num' do
      contract = Contract.generate_contract(start_date: start_date, end_date: end_date, price: 100)
      expect(contract.renting_phases.count).to eq(1)
    end


  end
end

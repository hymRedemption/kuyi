require 'rails_helper'

RSpec.describe Contract, type: :model do
  context '.generate_contract' do
    let(:start_date) { Date.new(2000, 1, 10) }
    let(:end_date) { Date.new(2000, 10, 8) }
    it 'generates contract' do
      contract = Contract.generate_contract(start_date: start_date, end_date: end_date, price: 100)
      expect(contract.is_a?(Contract)).to eq(true)
    end
  end
end

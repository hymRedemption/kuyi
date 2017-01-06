require 'rails_helper'

RSpec.describe Contract, type: :model do
  let(:start_date) { Date.new(2000, 1, 31) }
  let(:end_date) { Date.new(2000, 10, 8) }

  it 'should invalid if end_date smaller than start_date' do
    contract = FactoryGirl.build(:contract, start_date: start_date, end_date: start_date.days_ago(2))
    expect(contract.valid?).to eq(false)
  end

  context '.generate_contract' do
    let(:params) do
      {
        start_date: start_date,
        end_date: end_date,
        renting_phases: [
          {
            end_date: Date.new(2000, 2, 29),
            price: 100,
            cycles: 1
          },
          {
            end_date: Date.new(2000, 6, 10),
            price: 200,
            cycles: 3
          },
          {
            end_date: end_date,
            price: 300,
            cycles: 2
          }
        ]
      }
    end

    it 'generates contract' do
      contract = Contract.generate_contract(params)
      expect(contract.is_a?(Contract)).to eq(true)
    end

    context 'Renting Phase' do
      context 'valid operation' do
        let(:contract) { Contract.generate_contract(params) }
        it 'has same renting phases as we set' do
          expect(contract.renting_phases.count).to eq(3)
        end

        it 'has same price as we set of specific phase' do
          last_renting_phase = contract.renting_phases.order(:end_date).last
          expect(last_renting_phase.price).to eq(params[:renting_phases].last[:price])
        end

        it 'has same cicles as we set of specific phase' do
          last_renting_phase = contract.renting_phases.order(:end_date).last
          expect(last_renting_phase.cycles).to eq(params[:renting_phases].last[:cycles])
        end

        it 'has correct start_date' do
          last_renting_phase = contract.renting_phases.order(:end_date).last
          expect(last_renting_phase.start_date).to eq(Date.new(2000, 6, 11))
        end
      end

      context 'invalid operation' do
        it 'raise ArgumentError if end_date is earlier or equal than previous phase end_date' do
          first_phase_end_date = params[:renting_phases].first[:end_date]
          params[:renting_phases][1][:end_date] = first_phase_end_date
          expect { Contract.generate_contract(params) }.to raise_error(Contract::TimeRangeError)
        end

        it 'should rollback if any error happens' do
          skip
          params[:renting_phases][1][:cycles] = "invalid"
          expect{ Contract.generate_contract(params) }.not_to change{ Contract.count }
          expect{ Contract.generate_contract(params) }.not_to change{ RentingPhase.count }
        end
      end
    end
  end
end

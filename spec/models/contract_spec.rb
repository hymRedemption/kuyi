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
            start_date: start_date,
            price: 100,
            cycles: 1
          },
          {
            start_date: Date.new(2000, 3, 1),
            price: 200,
            cycles: 3
          },
          {
            start_date: Date.new(2000, 6, 11),
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
        it 'should rollback if any error happens' do
          params[:renting_phases][1][:cycles] = "invalid"
          expect do
            begin
              Contract.generate_contract(params)
            rescue ActiveRecord::RecordInvalid
            end
          end.not_to change{ Contract.count }
          expect do
            begin
              Contract.generate_contract(params)
            rescue ActiveRecord::RecordInvalid
            end
          end.not_to change{ RentingPhase.count }
        end
      end
    end
  end

  context '.normalize_param', skip: "should change 'normalize_param' to public first" do
    let(:params) do
      {
        start_date: Date.new(1999, 1, 1),
        end_date: Date.new(1999, 12, 12),
        renting_phases: [
          {
            price: 100,
            cycles: 1
          },
          {
            start_date: Date.new(1999, 2, 4),
            price: 200,
            cycles: 2
          },
          {
            start_date: Date.new(1999, 4, 6),
            price: 150,
            cycles: 5
          }
        ]
      }
    end

    context 'rules meeting' do
      it 'raise error if not all phases have start date except first phase' do
        params[:renting_phases].last[:start_date] = nil
        expect { Contract.normalize_param(params) }.to raise_error(Errors::NotMeetingRules)
      end
    end

    context 'date transform' do
      it 'transforms string to date if then string match date format' do
        params[:start_date] = "1999-1-1"
        result = Contract.normalize_param(params)
        expect(result[:start_date]).to eq(Date.new(1999, 1, 1))
      end

      it 'transforms other time related class to date' do
        params[:start_date] = Time.new(1999, 1, 1, 12)
        result = Contract.normalize_param(params)
        expect(result[:start_date]).to eq(Date.new(1999, 1, 1))
      end
    end

    context 'date check' do
      it 'raises error if date attr nest in renting phase is invalid' do
        params[:renting_phases][1][:end_date] = "invalid"
        expect{ Contract.normalize_param(params) }.to raise_error(Errors::InvalidDate)
      end

      it 'raises error if first renting phase start date is not same as contract start date' do
        params[:renting_phases].first[:start_date] = Date.new(1998, 12, 30)
        expect { Contract.normalize_param(params) }.to raise_error(Errors::InvalidDateRange)
      end

      it 'raises error if last renting phase end date is not same as contract end date' do
        params[:renting_phases].last[:end_date] = Date.new(1999, 11, 1)
        expect { Contract.normalize_param(params) }.to raise_error(Errors::InvalidDateRange)
      end

      it 'raises error if dates in renting phase is not logical' do
        params[:renting_phases][0][:end_date] = Date.new(1999, 2, 2)
        params[:renting_phases][1][:start_date] = Date.new(1999, 2, 2)
        expect { Contract.normalize_param(params) }.to raise_error(Errors::InvalidDateRange)
      end
    end

    context 'outcome' do
      it 'returns result that it is convience to use create model' do
        expect_result = {
          start_date: Date.new(1999, 1, 1),
          end_date: Date.new(1999, 12, 12),
          renting_phases: [
            {
              start_date: Date.new(1999, 1, 1),
              end_date: Date.new(1999, 2, 3),
              price: 100,
              cycles: 1
            },
            {
              start_date: Date.new(1999, 2, 4),
              end_date: Date.new(1999, 4, 5),
              price: 200,
              cycles: 2
            },
            {
              start_date: Date.new(1999, 4, 6),
              end_date: Date.new(1999, 12, 12),
              price: 150,
              cycles: 5
            }
          ]
        }
        result = Contract.normalize_param(params)
        expect(result).to eq(expect_result)
      end
    end
  end

  context '#generate_invoices' do
    let(:params) do
      {
        start_date: start_date,
        end_date: end_date,
        renting_phases: [
          {
            price: 100,
            cycles: 1
          },
          {
            start_date: Date.new(2000, 3, 1),
            price: 200,
            cycles: 3
          },
          {
            start_date: Date.new(2000, 6, 11),
            price: 300,
            cycles: 2
          }
        ]
      }
    end
    let(:contract) { Contract.generate_contract(params) }
    it 'returns a array' do
      result = contract.generate_invoices
      expect(result.respond_to?(:size)).to eq(true)
    end

    it 'returns correct count of invoices' do
      result = contract.generate_invoices
      expect(result.size).to eq(5)
    end

    it 'returns with correct start_time' do
      result = contract.generate_invoices
      expect(result[0].start_date).to eq(start_date)
      expect(result[1].start_date).to eq(Date.new(2000, 3, 1))
      expect(result[2].start_date).to eq(Date.new(2000, 6, 1))
      expect(result[3].start_date).to eq(Date.new(2000, 6, 11))
      expect(result[4].start_date).to eq(Date.new(2000, 8, 11))
    end

    it 'returns with correct total' do
      result = contract.generate_invoices
      expect(result[0].total).to eq(100)
      expect(result[1].total).to eq(3 * 200)
      expect(result[2].total.floor).to eq((200.0 * 12 /365 * 10).floor)
      expect(result[3].total).to eq(300 * 2)
      expect(result[4].total.floor).to eq((300 + 300.0 * 12 /365 * 28).floor)
    end
  end
end

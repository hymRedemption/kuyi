FactoryGirl.define do
  factory :renting_phase do
    start_date "2017-01-06"
    end_date "2017-01-06"
    price "9.99"
    cycles 1
    association :contract
  end
end

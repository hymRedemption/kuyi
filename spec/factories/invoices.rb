FactoryGirl.define do
  factory :invoice do
    start_date "2017-01-06"
    end_date "2017-01-06"
    due_date "2017-01-06"
    total "9.99"
    association :renting_phase
  end
end

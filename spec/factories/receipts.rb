FactoryGirl.define do
  factory :receipt do

    factory :sale do
      receipt_type 0
    end

    factory :purchase do
      receipt_type 0
    end

    factory :adjustment do
      receipt_type 1
    end
  end

end

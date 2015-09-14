FactoryGirl.define do
  factory :price do
    amount {rand(1000)}
    discount 10
  end

end

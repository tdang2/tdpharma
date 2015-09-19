FactoryGirl.define do
  factory :category do
    sequence(:name) {|n| "cat#{n}"}

    trait :with_discount do
      discount 10
    end

    trait :no_discount do
      discount 0
    end
  end

end

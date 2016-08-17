FactoryGirl.define do
  factory :transaction do
    amount 100
    total_price 120.5
    delivery_time DateTime.now
    due_date DateTime.now
    performed true
    paid true
    association :store, factory: :store
    association :inventory_item, factory: :inventory_item
    association :user, factory: :user

    trait :unpaid do
      paid false
    end

    trait :tbd do
      performed false
    end
  end

end

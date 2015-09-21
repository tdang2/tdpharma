FactoryGirl.define do
  factory :transaction do
    amount 100
    delivery_time DateTime.now
    due_date DateTime.now
    association :seller, factory: :store
    association :price, factory: :price
    association :seller_item, factory: :inventory_item

    trait :paid do
      paid true
    end

    trait :unpaid do
      paid false
    end

    trait :done do
      performed true
    end

    trait :tbd do
      performed false
    end

    after(:build) do |t|
      t.sale_user = t.seller.employees.first
    end
  end

end

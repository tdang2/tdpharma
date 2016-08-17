FactoryGirl.define do
  factory :purchase_transaction do
    amount 100
    total_price 120.5
    delivery_time DateTime.now
    due_date DateTime.now
    paid true
    performed true
    store
    user
    inventory_item
  end
end

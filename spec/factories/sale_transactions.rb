FactoryGirl.define do
  factory :sale_transaction do
    amount 10
    total_price 100
    delivery_time DateTime.now
    due_date DateTime.now
    paid true
    performed true
    store
    user
    inventory_item
  end
end
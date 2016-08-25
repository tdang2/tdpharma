FactoryGirl.define do
  factory :adjustment_transaction do
    amount 5
    total_price 200
    new_total 500
    delivery_time DateTime.now
    due_date DateTime.now
    paid true
    performed true
    receipt
    store
    user
    inventory_item
  end
end
FactoryGirl.define do
  factory :receipt do
    store

    factory :sale_receipt do |r|
      receipt_type 'sale'
    end

    factory :purchase_receipt do
      receipt_type 'purchase'
    end

    factory :adjustment_receipt do
      receipt_type 'adjustment'
    end
  end

end

FactoryGirl.define do
  factory :inventory_item do
    amount 100
    avg_purchase_price 10
    avg_sale_price 12
    avg_purchase_amount 50
    avg_sale_amount 10
    store

    after(:create)  do |t|
      t.sale_price = create(:price, priceable: t)
    end

    trait :with_med_batches do
      after(:create) do |t|
        t.med_batches << create(:med_batch)
      end
    end

  end

end

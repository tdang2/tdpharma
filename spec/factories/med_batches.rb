FactoryGirl.define do
  factory :med_batch do
    mfg_date {Date.today - 3.months}
    expire_date {Date.today + 3.months}
    package 'Box'
    amount_per_pkg 20
    amount_unit 'tablets'
    mfg_location 'Vietnam'
    total_units 100
    total_price 200.5
    association :user, factory: :user
    association :store, factory: :store
    association :medicine, factory: :medicine
  end

end

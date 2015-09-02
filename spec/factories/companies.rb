FactoryGirl.define do
  factory :company do
    sequence(:name) {|n| "Com#{n}"}
    sequence(:email) {|n| "Company#{n}@company.com"}
    description 'My awesome company'
    phone '123-123-1234'
    website 'company.com'
    association :location, factory: :location

    # Store association
    transient do
      stores_count 3
    end
    after(:create) do |com, eva|
      create_list(:store, eva.stores_count, company: com)
    end
  end

end

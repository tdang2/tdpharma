FactoryGirl.define do
  factory :store do
    sequence(:name) {|n| "Store#{n}"}
    phone '431-128-1298'
    company

    # Employee association
    transient do
      employees_count 4
    end
    after(:create) do  |store, eva|
      # Have to manually set role for employees during test. FactoryGirl will break if role are assigned here
      create_list(:user, eva.employees_count, store: store)
    end
  end

end

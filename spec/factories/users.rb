FactoryGirl.define do
  factory :user do
    sequence(:email) {|n| "me#{n}@email.com"}
    password 'password'
    sequence(:first_name) {|n| "Tri#{n}"}
    last_name 'Dang'
    store

    factory :owner do
      after(:create) do |u|
        u.roles << Role.find_or_create_by(name: 'owner')
        u.save!
      end
    end

    factory :manager do
      after(:create) do |u|
        u.roles << Role.find_or_create_by(name: 'manager')
        u.save!
      end
    end

    factory :employee do
      after(:create) do |u|
        u.roles << Role.find_or_create_by(name: 'employee')
        u.save!
      end
    end

  end

end

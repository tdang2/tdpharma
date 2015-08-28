FactoryGirl.define do
  factory :user do
    sequence(:email) {|n| "me#{n}@email.com"}
    password 'password'
    sequence(:first_name) {|n| "Tri#{n}"}
    last_name 'Dang'
    authentication_token SecureRandom.base64

    factory :owner do
      after(:create) do |u|
        u.roles << create(:owner_role)
      end
    end

    factory :manager do
      after(:create) do |u|
        u.roles << create(:manager_role)
      end
    end

    factory :employee do
      after(:create) do |u|
        u.roles << create(:employee_role)
      end
    end

  end

end

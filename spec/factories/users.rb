FactoryGirl.define do
  factory :user do
    sequence(:email) {|n| "me#{n}@email.com"}
    password 'password'
    sequence(:first_name) {|n| "Tri#{n}"}
    last_name 'Dang'
    authentication_token SecureRandom.base64
  end

end

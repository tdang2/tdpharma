FactoryGirl.define do
  factory :doorkeeper_access_token, class: Doorkeeper::AccessToken do
    expires_in 7200
  end
end
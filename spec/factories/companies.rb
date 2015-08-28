FactoryGirl.define do
  factory :company do
    sequence(:name) {|n| "Com#{n}"}
    sequence(:email) {|n| "Company#{n}@company.com"}
    description 'My awesome company'
    phone '123-123-1234'
    website 'company.com'
  end

end

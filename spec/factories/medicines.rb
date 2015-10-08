FactoryGirl.define do
  factory :medicine do
    sequence(:name) {|n| "med#{n}"}
    sequence(:concentration) {|n| n*100}
    concentration_unit 'mg'
    med_form 'tablet'
    association :image, factory: :image
  end

end

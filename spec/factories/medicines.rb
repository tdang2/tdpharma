FactoryGirl.define do
  factory :medicine do
    sequence(:name) {|n| "Med#{n}"}
    sequence(:concentration) {|n| n*100}
    concentration_unit 'mg'
    med_form 'tablet'
    mfg_location 'USA'
    association :image, factory: :image
  end

end

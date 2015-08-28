FactoryGirl.define do
  factory :role do
    name 'guest'

    factory :owner_role do
      name 'owner'
    end

    factory :manager_role do
      name 'manager'
    end

    factory :employee_role do
      name 'employee'
    end
  end

end

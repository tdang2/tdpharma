require 'rails_helper'

RSpec.describe User, type: :model do
  it {should validate_presence_of :email}
  it {should validate_presence_of :password}
  it {should validate_presence_of :first_name}
  it {should validate_presence_of :last_name}
  it {should validate_uniqueness_of :email}
  it {should have_and_belong_to_many :roles}
  it {should have_many :employees}
  it {should belong_to :manager}
  it {should belong_to :store}

  it {expect(create(:owner)).to be_valid}
  it {expect(create(:manager)).to be_valid}
  it {expect(create(:employee)).to be_valid}

end

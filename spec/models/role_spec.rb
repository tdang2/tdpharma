require 'rails_helper'

RSpec.describe Role, type: :model do
  it {should validate_presence_of :name}
  it {should validate_uniqueness_of :name}
  it {should have_and_belong_to_many :users}

end

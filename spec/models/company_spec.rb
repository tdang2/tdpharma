require 'rails_helper'

RSpec.describe Company, type: :model do
  it {should validate_presence_of :name}
  it {should have_many :stores}
  it {should have_many :locations}
  it {should have_many :employees}
  it {should have_one :image}
  it {should have_one :registered_location}
  it {should have_many :documents}

end

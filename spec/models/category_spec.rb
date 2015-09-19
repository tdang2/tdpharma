require 'rails_helper'

RSpec.describe Category, type: :model do
  it {should validate_presence_of :name}
  it {should have_many :inventory_items}
  it {should have_and_belong_to_many :stores}

end

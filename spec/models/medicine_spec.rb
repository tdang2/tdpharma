require 'rails_helper'

RSpec.describe Medicine, type: :model do
  it {should validate_presence_of :name}
  it {should validate_presence_of :med_form}
  it {should have_many :med_batches}
  it {should have_many :inventory_items}
  it {should have_one :image}
end

require 'rails_helper'

RSpec.describe MedBatch, type: :model do
  it {should validate_presence_of :mfg_date}
  it {should validate_presence_of :expire_date}
  it {should validate_presence_of :package}
  it {should validate_presence_of :amount_per_pkg}
  it {should validate_presence_of :amount_unit}
  it {should have_and_belong_to_many :inventory_items}
  it {should belong_to :medicine}

end

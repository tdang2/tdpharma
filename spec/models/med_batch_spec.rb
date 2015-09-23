require 'rails_helper'

RSpec.describe MedBatch, type: :model do
  it {should validate_presence_of :mfg_date}
  it {should validate_presence_of :expire_date}
  it {should validate_presence_of :package}
  it {should validate_presence_of :amount_per_pkg}
  it {should validate_presence_of :amount_unit}
  it {should belong_to :inventory_item}
  it {should belong_to :medicine}
  it {should belong_to :user}

end

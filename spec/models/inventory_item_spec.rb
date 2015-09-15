require 'rails_helper'

RSpec.describe InventoryItem, type: :model do
  it {should belong_to :store}
  it {should have_and_belong_to_many :med_batches}
  it {should have_one(:medicine).through(:med_batches)}
end

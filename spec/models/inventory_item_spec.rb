require 'rails_helper'

RSpec.describe InventoryItem, type: :model do
  it {should belong_to :store}
  it {should belong_to :category}
  it {should have_many :med_batches}
  it {should have_many :good_batches}
  it {should have_many :empty_batches}
  it {should have_many :available_batches}
  it {should belong_to :itemable}
  it {should have_many :purchases}
  it {should have_many :sales}
  it {should have_many :adjustments}
  it {should have_one :sale_price}
  it {should have_one :image}

end

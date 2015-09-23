require 'rails_helper'

RSpec.describe Store, type: :model do
  it {should validate_presence_of :name}
  it {should have_many :employees}
  it {should belong_to :company}
  it {should have_one :location}
  it {should have_one :image}
  it {should have_many :documents}
  it {should have_many :inventory_items}
  it {should have_many :med_batches}
  it {should have_and_belong_to_many :categories}
  it {should have_many :purchases}
  it {should have_many :sales}

end

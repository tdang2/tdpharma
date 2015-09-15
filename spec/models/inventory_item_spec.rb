require 'rails_helper'

RSpec.describe InventoryItem, type: :model do
  it {should have_and_belong_to_many :medicines}

end

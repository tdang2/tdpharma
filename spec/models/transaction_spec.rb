require 'rails_helper'

RSpec.describe Transaction, type: :model do
  it {should belong_to :store}
  it {should belong_to :user}
  it {should belong_to :inventory_item}
  it {should belong_to :receipt}
  it {should belong_to :med_batch}

end

require 'rails_helper'

RSpec.describe Transaction, type: :model do
  it {should belong_to :buyer}
  it {should belong_to :seller}
  it {should belong_to :adjust_store}
  it {should belong_to :purchase_user}
  it {should belong_to :sale_user}
  it {should belong_to :adjust_user}
  it {should belong_to :seller_item}
  it {should belong_to :buyer_item}
  it {should belong_to :adjust_item}
  it {should belong_to :receipt}
  it {should belong_to :med_batch}

end

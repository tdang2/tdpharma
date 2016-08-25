require 'rails_helper'

RSpec.describe Receipt, type: :model do
  it {should belong_to :store}
  it {should have_many :transactions}
  it {should have_many :med_batches}
  it {should have_many :purchase_transactions}
  it {should have_many :sale_transactions}
  it {should have_many :adjustment_transactions}

end

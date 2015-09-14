require 'rails_helper'

RSpec.describe Price, type: :model do
  it {should belong_to :priceable}
end

require 'rails_helper'

RSpec.describe Location, type: :model do
  it {should validate_presence_of :address}
  it {should belong_to :locationable}
  it {expect(create(:location)).to have_attributes(:longitude => -71.0508825, :latitude => 42.3601891)}

end

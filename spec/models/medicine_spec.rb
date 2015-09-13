require 'rails_helper'

RSpec.describe Medicine, type: :model do
  it {should validate_presence_of :name}
  it {should validate_presence_of :concentration}
  it {should validate_presence_of :concentration_unit}
  it {should validate_presence_of :med_form}
end

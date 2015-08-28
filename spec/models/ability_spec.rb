require 'rails_helper'

RSpec.describe Ability do
  describe 'Owner abilities' do
    before do
      @owner = create(:owner)
      @abilities = Ability.new(@owner)
    end
    it {expect(@abilities).to have_abilities(:read, :all)}
    it {expect(@abilities).to have_abilities(:manage, User)}
    it {expect(@abilities).to have_abilities(:assign_roles, User)}
  end

end
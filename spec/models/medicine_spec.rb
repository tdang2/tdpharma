require 'rails_helper'

RSpec.describe Medicine, type: :model do
  it {should validate_presence_of :name}
  it {should validate_presence_of :med_form}
  it {should have_many :med_batches}
  it {should have_many :inventory_items}
  it {should have_one :image}
  describe 'association behavior' do
    describe 'when deleted' do
      it 'destroy all related inventory items from all stores' do

      end
      it 'destroy all related med_batches' do

      end
      it 'destroy the related image' do

      end
    end
  end

end

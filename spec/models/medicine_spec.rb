require 'rails_helper'

RSpec.describe Medicine, type: :model do
  it {should validate_presence_of :name}
  it {should validate_presence_of :med_form}
  it {should have_many :med_batches}
  it {should have_many :inventory_items}
  it {should have_one :image}

  describe 'association behavior' do
    include_context 'user params'
    include_context 'category params'
    include_context 'medicine params'
    before do
      prepare_data
    end
    let(:b1) {create(:med_batch, category_id: c3.id, user: u2, store: s, medicine: med1, total_price: 200, total_units: 100, amount_per_pkg: 5, number_pkg: 20)}
    let(:b2) {create(:med_batch, category_id: c2.id, user: u1s2, store: s2, medicine: med1, total_price: 250, total_units: 250, amount_per_pkg: 50, number_pkg: 5)}
    describe 'when deleted' do
      it 'destroy all related inventory items from all stores' do
        i1 = b1.inventory_item.id
        i2 = b2.inventory_item.id
        med1.destroy
        expect{InventoryItem.find(i1)}.to raise_error ActiveRecord::RecordNotFound
        expect{InventoryItem.find(i2)}.to raise_error ActiveRecord::RecordNotFound
      end
      it 'destroy all related med_batches' do
        i1 = b1.id
        i2 = b2.id
        med1.destroy
        expect{MedBatch.find(i1)}.to raise_error ActiveRecord::RecordNotFound
        expect{MedBatch.find(i2)}.to raise_error ActiveRecord::RecordNotFound
      end
    end
  end

end

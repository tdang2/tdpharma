require 'rails_helper'
require 'helpers/user_helper'
require 'helpers/category_helper'
require 'helpers/medicine_helper_spec'

RSpec.describe MedBatch, type: :model do
  it {should validate_presence_of :mfg_date}
  it {should validate_presence_of :expire_date}
  it {should validate_presence_of :package}
  it {should validate_presence_of :amount_per_pkg}
  it {should validate_presence_of :amount_unit}
  it {should belong_to :inventory_item}
  it {should belong_to :medicine}
  it {should belong_to :user}
  it {should belong_to :category}

  describe 'create inventory item callback' do
    include_context 'user params'
    include_context 'category params'
    include_context 'medicine params'
    before do
      prepare_data
    end
    it 'create an inventory item' do
      batch1 = create(:med_batch, category_id: @c3.id, user: u2, store: s, medicine: med1)
      expect(batch1.inventory_item).not_to eq nil
    end
    it 'update existing inventory item' do
      create(:med_batch, category_id: @c3.id, user: u2, store: s, medicine: med1)
      b2 = create(:med_batch, category_id: @c3.id, user: u2, store: s, medicine: med1)
      expect(b2.inventory_item.med_batches.count).to eq 2
      expect(b2.inventory_item.purchases.count).to eq 2
    end
    it 'update inventory item avg purchase values' do
      create(:med_batch, category_id: @c3.id, user: u2, store: s, medicine: med1, total_price: 200, total_units: 100)
      b2 = create(:med_batch, category_id: @c3.id, user: u2, store: s, medicine: med1, total_price: 300, total_units: 300)
      expect(b2.inventory_item.amount).to eq 400
      expect(b2.inventory_item.avg_purchase_price).to eq 250
      expect(b2.inventory_item.avg_purchase_amount).to eq 200
    end
    it 'update inventory item image' do
      create(:med_batch, category_id: @c3.id, user: u2, store: s, medicine: med1, total_price: 200, total_units: 100)
      b2 = create(:med_batch, category_id: @c3.id, user: u2, store: s, medicine: med1, total_price: 300, total_units: 300)
      expect(b2.inventory_item.image).not_to eq nil
    end
  end

end

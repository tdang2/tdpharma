require 'rails_helper'

RSpec.describe MedBatch, type: :model do
  it {should belong_to :inventory_item}
  it {should belong_to :medicine}
  it {should belong_to :user}
  it {should belong_to :category}
  it {should belong_to :receipt}
  it {should have_many :purchase_transactions}
  it {should have_many :sale_transactions}
  it {should have_many :adjustment_transactions}

  describe 'create inventory item callback' do
    include_context 'user params'
    include_context 'category params'
    include_context 'medicine params'
    before do
      prepare_data
    end
    it 'have consistent quantities' do
      batch = build(:med_batch, category_id: c3.id, user: u2, store: s, medicine: med1, amount_per_pkg: 10, number_pkg: 5, total_units: 60)
      expect(batch).not_to be_valid
    end

    it 'create an inventory item' do
      batch1 = create(:med_batch, category_id: c3.id, user: u2, store: s, medicine: med1)
      expect(batch1.inventory_item).not_to eq nil
      expect(batch1.barcode).not_to eq nil
    end
    it 'update existing inventory item' do
      create(:med_batch, category_id: c3.id, user: u2, store: s, medicine: med1)
      b2 = create(:med_batch, category_id: c3.id, user: u2, store: s, medicine: med1, paid: false)
      expect(b2.inventory_item.med_batches.count).to eq 2
      expect(b2.inventory_item.med_batches.last.paid).to eq false
      expect(b2.inventory_item.purchase_transactions.count).to eq 2
      expect(b2.inventory_item.purchase_transactions.last.paid).to eq false
    end
    it 'update inventory item avg purchase values' do
      create(:med_batch, category_id: c3.id, user: u2, store: s, medicine: med1, total_price: 200, total_units: 100, amount_per_pkg: 10, number_pkg: 10)
      b2 = create(:med_batch, category_id: c3.id, user: u2, store: s, medicine: med1, total_price: 300, total_units: 300, amount_per_pkg: 150, number_pkg: 2)
      expect(b2.inventory_item.amount).to eq 400
      expect(b2.inventory_item.avg_purchase_price).to eq 250
      expect(b2.inventory_item.avg_purchase_amount).to eq 200
    end
    it 'update inventory item image' do
      create(:med_batch, category_id: c3.id, user: u2, store: s, medicine: med1, total_price: 200, total_units: 100, amount_per_pkg: 10, number_pkg: 10)
      b2 = create(:med_batch, category_id: c3.id, user: u2, store: s, medicine: med1, total_price: 300, total_units: 300, amount_per_pkg: 1, number_pkg: 300)
      expect(b2.inventory_item.image).not_to eq nil
    end
  end

end

require 'rails_helper'

RSpec.describe MedBatch, type: :model do
  include_context 'user params'
  include_context 'category params'
  include_context 'medicine params'
  include_context 'inventory item params'

  it {should belong_to :inventory_item}
  it {should belong_to :medicine}
  it {should belong_to :user}
  it {should belong_to :category}
  it {should belong_to :receipt}
  it {should have_many :purchase_transactions}
  it {should have_many :sale_transactions}
  it {should have_many :adjustment_transactions}

  describe 'create inventory item callback' do
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
    end
  end

  describe 'scope spec' do
    before do
      prepare_data
      u1.update!(store_id: s.id)
      item1.create_sale_price(amount: 100, discount: 0)
      item2.create_sale_price(amount: 150, discount: 0)
      item3
    end

    it 'by_barcode' do
      batches = MedBatch.by_barcode(item1.med_batches.first.barcode)
      expect(batches.first).to eq item1.med_batches.first
      expect(batches.first.inventory_item).to eq item1
      expect(batches.count).to eq 1
    end

    it 'available batches' do
      item2.med_batches.each {|b| b.update!(total_units: 0, number_pkg: 0)}
      batches = MedBatch.available_batches
      expect(batches.map{|b| b.inventory_item}).not_to include item2
    end
  end

end

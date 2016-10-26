require 'rails_helper'

RSpec.describe Transaction, type: :model do
  include_context 'user params'
  include_context 'category params'
  include_context 'medicine params'
  include_context 'inventory item params'
  include_context 'receipt params'

  it {should belong_to :store}
  it {should belong_to :user}
  it {should belong_to :inventory_item}
  it {should belong_to :receipt}
  it {should belong_to :med_batch}

  describe 'has_scope' do
    before do
      prepare_data
      item1
      item2
      item3
      item4
      @m = create(:med_batch, category_id: c3.id, user: u1, store: s, medicine: med1)
      attrs = [
          attributes_for(:med_batch, user_id: u1.id, category: c3, medicine_id: med1.id, store_id: s.id),
          attributes_for(:med_batch, user_id: u1.id, category: c3, medicine_id: med1.id, store_id: s.id)
      ]
      create(:receipt, store: s, med_batches_attributes: attrs)
      attrs = [
          attributes_for(:sale_transaction, amount: 20, store_id: s.id, user_id: u1.id, inventory_item_id: item1.id, med_batch_id: item1.med_batches.first.id),
          attributes_for(:sale_transaction, amount: 30, store_id: s.id, user_id: u1.id, inventory_item_id: item1.id, med_batch_id: item1.med_batches.last.id)
      ]
      create(:sale_receipt, store: s, sale_transactions_attributes: attrs)
    end

    it 'purchase transaction' do
      expect(Transaction.purchase.all? {|p| p.transaction_type == 'purchase'}).to eq true
    end

    it 'sale transaction' do
      expect(Transaction.sale.all? {|p| p.transaction_type == 'sale'}).to eq true
    end

    it 'adjustment transaction' do
      create(:transaction, transaction_type: 'adjustment', store: s)
      create(:transaction, transaction_type: 'adjustment', store: s)
      expect(Transaction.adjustment.all? {|p| p.transaction_type == 'adjustment'}).to eq true
    end

    it 'by_user' do
      expect(Transaction.by_user(u1.id).all? {|p| p.user_id == u1.id}).to eq true
      expect(Transaction.by_user(u1.id).map(&:transaction_type).uniq).to include 'purchase', 'sale'
    end

    it 'by_med_batch' do
      expect(Transaction.by_med_batch(item1.med_batches.first.id).all? {|p| p.med_batch_id == item1.med_batches.first.id}).to eq true
      expect(Transaction.by_med_batch(item1.med_batches.first.id).map(&:transaction_type).uniq).to include 'purchase', 'sale'
    end

    it 'by_inventory_item' do
      expect(Transaction.by_inventory_item(item1.id).all? {|p| p.inventory_item_id == item1.id}).to eq true
      expect(Transaction.by_inventory_item(item1.id).map(&:transaction_type).uniq).to include 'purchase', 'sale'
    end

    it 'active' do
      expect(Transaction.active.all? {|p| p.status == 'active'}).to eq true
    end

  end

end

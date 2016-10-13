require 'rails_helper'

RSpec.describe SaleTransaction do

  include_context 'user params'
  include_context 'category params'
  include_context 'medicine params'
  include_context 'inventory item params'
  include_context 'receipt params'

  describe 'testing callbakcs' do
    before do
      prepare_data
    end

    it 'two batches same item in single receipt' do
      # first generate store item
      item1
      create(:med_batch, category_id: c3.id, user: u1, store: s, medicine: med1)
      expect(item1.reload.amount).to eq 200

      attrs = [
          attributes_for(:sale_transaction, amount: 20, store_id: s.id, user_id: u1.id, inventory_item_id: item1.id, med_batch_id: item1.med_batches.first.id),
          attributes_for(:sale_transaction, amount: 30, store_id: s.id, user_id: u1.id, inventory_item_id: item1.id, med_batch_id: item1.med_batches.last.id)
      ]
      create(:sale_receipt, store: s, sale_transactions_attributes: attrs)
      expect(item1.med_batches.first.reload.total_units).to eq 80
      expect(item1.med_batches.last.reload.total_units).to eq 70
      expect(item1.reload.amount).to eq 150
    end

    it 'different items in single receipt' do
      item1
      item2
      attrs = [
          attributes_for(:sale_transaction, amount: 20, store_id: s.id, user_id: u1.id, inventory_item_id: item1.id, med_batch_id: item1.med_batches.first.id),
          attributes_for(:sale_transaction, amount: 30, store_id: s.id, user_id: u1.id, inventory_item_id: item2.id, med_batch_id: item2.med_batches.first.id)
      ]
      create(:receipt, store: s, sale_transactions_attributes: attrs)
      expect(item1.reload.amount).to eq 80
      expect(item2.reload.amount).to eq 70
    end
  end

end
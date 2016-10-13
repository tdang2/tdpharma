require 'rails_helper'

RSpec.describe PurchaseTransaction do
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
      attrs = [
          attributes_for(:med_batch, user_id: u1.id, category: c3, medicine_id: med1.id, store_id: s.id),
          attributes_for(:med_batch, user_id: u1.id, category: c3, medicine_id: med1.id, store_id: s.id)
      ]
      r = create(:receipt, store: s, med_batches_attributes: attrs)
      expect(item1.reload.amount).to eq 300
    end

    it 'different items in single receipt' do
      item1
      item2
      attrs = [
          attributes_for(:med_batch, user_id: u1.id, category: c3, medicine_id: med1.id, store_id: s.id),
          attributes_for(:med_batch, user_id: u1.id, category: c2, medicine_id: med2.id, store_id: s.id)
      ]
      r = create(:receipt, store: s, med_batches_attributes: attrs)
      expect(item1.reload.amount).to eq 200
      expect(item2.reload.amount).to eq 200
    end
  end
end
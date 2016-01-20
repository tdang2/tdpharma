require 'rails_helper'

RSpec.describe Api::V1::TransactionsController, type: :controller do
  include_context 'user params'
  include_context 'category params'
  include_context 'medicine params'
  include_context 'inventory item params'
  include_context 'receipt params'

  before do
    prepare_data
    u1.update!(store_id: s.id)
  end

  describe 'show GET' do
    before do
      request.headers['Authorization'] = "Bearer #{u1.authentication_token}"
    end
    it 'show correct purchase' do
      r = Receipt.create!(purchase_receipt_params)
      t_id = item1.purchases.last.id
      get :show, id: t_id, format: :json
      expect(response.status).to eq 200
      expect(JSON.parse(response.body)['data']['receipt']['receipt_type']).to eq 'purchase'
      expect(JSON.parse(response.body)['data']['buyer_item']['id']).to eq item1.id
      expect(r.med_batches.map(&:id)).to include JSON.parse(response.body)['data']['med_batch']['id']
    end

    it 'show correct sale' do
      item1.create_sale_price(amount: 100, discount: 0)   # initialized 100 units for item1
      item4.create_sale_price(amount: 100, discount: 0)   # initialized 100 units for item4
      r = Receipt.create!(sale_receipt_params)
      t_id = item4.sales.last.id
      get :show, id: t_id, format: :json
      expect(response.status).to eq 200
      expect(JSON.parse(response.body)['data']['receipt']['receipt_type']).to eq 'sale'
      expect(JSON.parse(response.body)['data']['seller_item']['id']).to eq item4.id
      expect(r.transactions.map {|t| t.med_batch.id}).to include JSON.parse(response.body)['data']['med_batch']['id']
    end

    it 'show correct adjustment' do
      item2.create_sale_price(amount: 100, discount: 0)   # initialized 100 units for item2
      item3.create_sale_price(amount: 100, discount: 0)   # initialized 100 units for item3
      r = Receipt.create!(adjust_receipt_params)
      t_id = item3.adjustments.last.id
      get :show, id: t_id, format: :json
      expect(response.status).to eq 200
      expect(JSON.parse(response.body)['data']['receipt']['receipt_type']).to eq 'adjustment'
      expect(JSON.parse(response.body)['data']['adjust_item']['id']).to eq item3.id
      expect(JSON.parse(response.body)['data']['med_batch']).to be nil
    end
  end
end
require 'rails_helper'

RSpec.describe Api::V1::ReceiptsController, type: :controller do
  include_context 'user params'
  include_context 'category params'
  include_context 'medicine params'
  include_context 'inventory item params'
  include_context 'transaction params'

  before do
    prepare_data
    u1.update!(store_id: s.id)
    item1.create_sale_price(amount: 100, discount: 0)   # initialized 100 units for item1
    item2.create_sale_price(amount: 150, discount: 0)   # initialized 100 units for item2
    item3.create_sale_price(amount: 30, discount: 0)    # initialized 100 units for item3
    item4.create_sale_price(amount: 54, discount: 0)    # initialized 100 units for item4
  end

  describe 'GET index' do
    before do
      Receipt.create!(purchase_receipt_params)
      Receipt.create!(sale_receipt_params)
      Receipt.create!(adjust_receipt_params)
      request.headers['Authorization'] = "Bearer #{u1.authentication_token}"
    end
    it 'list all receipts' do
      get :index, format: :json
      expect(response.status).to eq 200
      expect(JSON.parse(response.body)['data'].count).to be >= 3
    end
    it 'list all sales' do
      get :index, sale: true, format: :json
      expect(response.status).to eq 200
      expect(JSON.parse(response.body)['data'].all?{|r| r['receipt_type'] == 'sale' and r['transactions'].all?{|t| !t['seller_item_id'].nil?}}).to eq true
    end
    it 'list all purchases' do
      get :index, purchase: true, format: :json
      expect(response.status).to eq 200
      expect(JSON.parse(response.body)['data'].all?{|r| r['receipt_type'] == 'purchase' and r['transactions'].all?{|t| !t['buyer_item_id'].nil?}}).to eq true
    end
    it 'list all adjustment' do
      get :index, adjustment: true, format: :json
      expect(response.status).to eq 200
      expect(JSON.parse(response.body)['data'].all?{|r| r['receipt_type'] == 'adjustment' and r['transactions'].all?{|t| !t['adjust_item_id'].nil?}}).to eq true
    end
  end

  describe 'CREATE post' do
    before do
      request.headers['Authorization'] = "Bearer #{u1.authentication_token}"
    end
    it 'create purchase receipt' do
      item1_cnt = InventoryItem.find(item1.id).amount
      item2_cnt = InventoryItem.find(item2.id).amount
      item3_cnt = InventoryItem.find(item3.id).amount
      post :create, receipt: purchase_receipt_controller_params, format: :json
      expect(response.status).to eq 200
      expect(InventoryItem.find(item1.id).amount).to eq item1_cnt + 100
      expect(InventoryItem.find(item2.id).amount).to eq item2_cnt + 54
      expect(InventoryItem.find(item3.id).amount).to eq item3_cnt + 27
      expect(JSON.parse(response.body)['data']['receipt_type'] == 'purchase').to eq true
      expect(JSON.parse(response.body)['data']['transactions'].all?{|t| !t['buyer_item_id'].nil?}).to eq true
    end
    it 'create sale receipt' do
      item1_cnt = InventoryItem.find(item1.id).amount
      item4_cnt = InventoryItem.find(item4.id).amount
      post :create, receipt: sale_receipt_controller_params, format: :json
      expect(response.status).to eq 200
      expect(InventoryItem.find(item1.id).amount).to eq item1_cnt - 1
      expect(InventoryItem.find(item4.id).amount).to eq item4_cnt - 1
      expect(JSON.parse(response.body)['data']['receipt_type'] == 'sale').to eq true
      expect(JSON.parse(response.body)['data']['transactions'].all?{|t| !t['seller_item_id'].nil?}).to eq true
    end
    it 'create adjustment receipt' do
      item2_cnt = InventoryItem.find(item2.id).amount
      item3_cnt = InventoryItem.find(item3.id).amount
      post :create, receipt: adjust_receipt_controller_params, format: :json
      expect(response.status).to eq 200
      expect(InventoryItem.find(item2.id).amount).to eq item2_cnt - 20
      expect(InventoryItem.find(item3.id).amount).to eq item3_cnt + 10
      expect(JSON.parse(response.body)['data']['receipt_type'] == 'adjustment').to eq true
      expect(JSON.parse(response.body)['data']['transactions'].all?{|t| !t['adjust_item_id'].nil?}).to eq true
    end
  end
end
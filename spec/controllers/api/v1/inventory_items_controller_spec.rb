require 'rails_helper'

RSpec.describe Api::V1::InventoryItemsController, type: :controller do
  include_context 'user params'
  include_context 'category params'
  include_context 'medicine params'
  include_context 'inventory item params'

  before do
    prepare_data
    u1.update!(store_id: s.id)
    item1.create_sale_price(amount: 100, discount: 0)
    item2.create_sale_price(amount: 150, discount: 0)
    item4
    item3.update!(status: 'inactive')
  end

  describe 'GET index' do
    it 'should return active inventory items' do
      request.headers['Authorization'] = "Bearer #{u1.authentication_token}"
      get :index, format: :json
      expect(response.status).to eq 200
      expect(JSON.parse(response.body)['data']['items'].count).to be >= 3
      expect(JSON.parse(response.body)['data']['items'].collect{|u| u['id']}).not_to include item3.id
      expect(JSON.parse(response.body)['data']['items'].collect{|u| u['itemable']}).not_to include nil
    end
    it 'should return inactive inventory items' do
      request.headers['Authorization'] = "Bearer #{u1.authentication_token}"
      get :index, inactive: true, format: :json
      expect(response.status).to eq 200
      expect(JSON.parse(response.body)['data']['items'].collect{|u| u['id']}).to include item3.id
      expect(JSON.parse(response.body)['data']['items'].collect{|u| u['sale_price']}).to include nil
    end
    it 'should return active item belong to c2' do
      request.headers['Authorization'] = "Bearer #{u1.authentication_token}"
      get :index, category_id: c2.id, format: :json
      expect(response.status).to eq 200
      expect(JSON.parse(response.body)['data']['items'].collect{|u| u['id']}).to match [item2.id, item4.id]
    end
  end

  describe 'GET show' do
    it 'should return the inventory items' do
      request.headers['Authorization'] = "Bearer #{u1.authentication_token}"
      get :show, id: item1.id, format: :json
      expect(response.status).to eq 200
      expect(JSON.parse(response.body)['data']['id']).to eq item1.id
    end
  end

  describe 'PATCH update' do
    it 'turn inventory to inactive' do
      request.headers['Authorization'] = "Bearer #{u1.authentication_token}"
      patch :update, id: item1.id, format: :json, inventory_item: {status: 'inactive'}
      expect(response.status).to eq 200
      expect(JSON.parse(response.body)['data']['id']).to eq item1.id
      expect(JSON.parse(response.body)['data']['status']).to eq 'inactive'
    end
    it 'create sale price for inventory' do
      request.headers['Authorization'] = "Bearer #{u1.authentication_token}"
      patch :update, id: item4.id, format: :json, inventory_item: inventory_item_new_price_params
      expect(response.status).to eq 200
      expect(JSON.parse(response.body)['data']['id']).to eq item4.id
      expect(JSON.parse(response.body)['data']['sale_price']['amount']).to eq 200
    end
    it 'update sale price for inventory' do
      request.headers['Authorization'] = "Bearer #{u1.authentication_token}"
      patch :update, id: item1.id, inventory_item: inventory_item_price_params, format: :json
      expect(response.status).to eq 200
      expect(JSON.parse(response.body)['data']['id']).to eq item1.id
      expect(JSON.parse(response.body)['data']['sale_price']['amount']).to eq 200
    end
  end

end
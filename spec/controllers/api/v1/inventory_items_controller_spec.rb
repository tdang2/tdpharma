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
    request.headers['Authorization'] = "Bearer #{u1.authentication_token}"
  end

  describe 'GET index' do
    it 'should return active inventory items' do
      get :index, active: true, format: :json
      expect(response.status).to eq 200
      expect(JSON.parse(response.body)['data']['items'].count).to be >= 3
      expect(JSON.parse(response.body)['data']['items'].collect{|u| u['id']}).not_to include item3.id
      expect(JSON.parse(response.body)['data']['items'].collect{|u| u['itemable']}).not_to include nil
      expect(JSON.parse(response.body)['data']['items'].all? {|i| i['available_batches'].all? {|t| t['status'] == 'active'}}).to eq true
    end
    it 'not include deprecated med_batch' do
      item4.med_batches.last.update!(status: 'deprecated')
      get :index, active: true, format: :json
      expect(response.status).to eq 200
      result = JSON.parse(response.body)['data']['items'].find {|i| i['id'] == item4.id}
      expect(result['available_batches'].all?{|b| b['status'] == 'deprecated'}).to be true
    end
    it 'should return inactive inventory items' do
      get :index, active: false, format: :json
      expect(response.status).to eq 200
      expect(JSON.parse(response.body)['data']['items'].collect{|u| u['id']}).to include item3.id
      expect(JSON.parse(response.body)['data']['items'].collect{|u| u['sale_price']}).to include nil
      expect(JSON.parse(response.body)['data']['items'].all? {|i| i['available_batches'].all? {|t| t['status'] == 'active'}}).to eq true
    end
    it 'should return active item belong to c2' do
      get :index, category_id: c2.id, format: :json
      expect(response.status).to eq 200
      expect(JSON.parse(response.body)['data']['items'].collect{|u| u['id']}).to include item2.id
      expect(JSON.parse(response.body)['data']['items'].collect{|u| u['id']}).to include item4.id
      expect(JSON.parse(response.body)['data']['items'].all? {|i| i['available_batches'].all? {|t| t['status'] == 'active'}}).to eq true
    end
    it 'should return item search by name' do
      item1.itemable.update(name: 'Calcium')
      item2.itemable.update(name: 'Calculus')
      get :index, search: 'Calc', format: :json
      expect(response.status).to eq 200
      expect(JSON.parse(response.body)['data']['items'].all?{|i| i['itemable']['name'].include?('Calc')}).to eq true
      expect(JSON.parse(response.body)['data']['items'].all? {|i| i['available_batches'].all? {|t| t['status'] == 'active'}}).to eq true
    end
    it 'look up item name with titleize format' do
      item1.itemable.update(name: 'Calcium Light')
      get :index, search: 'calcium light', format: :json
      expect(response.status).to eq 200
      expect(JSON.parse(response.body)['data']['items'].all?{|i| i['itemable']['name'].include?('Calcium Light')}).to eq true
      expect(JSON.parse(response.body)['data']['items'].all? {|i| i['available_batches'].all? {|t| t['status'] == 'active'}}).to eq true
    end
    describe 'with interested  item id' do
      it 'return page of items' do
        get :index, inventory_id: item1.id, format: :json
        expect(response.status).to eq 200
        expect(JSON.parse(response.body)['data']['items'].any?{|i| i['itemable']['name'] == item1.itemable.name}).to eq true
      end

      it 'works regardless of item state' do
        get :index, inventory_id: item3.id, format: :json
        expect(response.status).to eq 200
        expect(JSON.parse(response.body)['data']['items'].any?{|i| i['itemable']['name'] == item3.itemable.name}).to eq true
      end
    end

  end

  describe 'GET show' do
    it 'should return the inventory items' do
      request.headers['Authorization'] = "Bearer #{u1.authentication_token}"
      get :show, id: item1.id, format: :json
      expect(response.status).to eq 200
      expect(JSON.parse(response.body)['data']['id']).to eq item1.id
      expect(item1.med_batches.map(&:id)).to include JSON.parse(response.body)['data']['available_batches'][0]['id']
      expect(Float(JSON.parse(response.body)['data']['available_batches'][0]['total_units'])).to be > 0
      expect(JSON.parse(response.body)['data']['available_batches'].all? {|t| t['status'] == 'active'}).to eq true
    end
    it 'should return inventory with no empty batches' do
      b  = item1.med_batches.last.update!(total_units: 0, number_pkg: 0)
      request.headers['Authorization'] = "Bearer #{u1.authentication_token}"
      get :show, id: item1.id, format: :json
      expect(response.status).to eq 200
      expect(JSON.parse(response.body)['data']['id']).to eq item1.id
      expect(JSON.parse(response.body)['data']['available_batches']).to eq []
    end
    it 'should return inventory with no deprecated batches' do
      item1.med_batches.last.update!(status: 'deprecated')
      request.headers['Authorization'] = "Bearer #{u1.authentication_token}"
      get :show, id: item1.id, format: :json
      expect(response.status).to eq 200
      expect(JSON.parse(response.body)['data']['id']).to eq item1.id
      expect(JSON.parse(response.body)['data']['available_batches']).to eq []
    end
  end

  describe 'PATCH update' do
    it 'turn inventory to inactive' do
      request.headers['Authorization'] = "Bearer #{u1.authentication_token}"
      patch :update, id: item1.id, format: :json, inventory_item: {status: 'inactive'}
      expect(response.status).to eq 200
      expect(JSON.parse(response.body)['data']['id']).to eq item1.id
      expect(JSON.parse(response.body)['data']['status']).to eq 'inactive'
      expect(JSON.parse(response.body)['data']['available_batches'].all? {|t| t['status'] == 'active'}).to eq true
    end
    it 'create sale price for inventory' do
      request.headers['Authorization'] = "Bearer #{u1.authentication_token}"
      patch :update, id: item4.id, format: :json, inventory_item: inventory_item_new_price_params
      expect(response.status).to eq 200
      expect(JSON.parse(response.body)['data']['id']).to eq item4.id
      expect(JSON.parse(response.body)['data']['sale_price']['amount']).to eq 200
      expect(JSON.parse(response.body)['data']['available_batches'].all? {|t| t['status'] == 'active'}).to eq true
    end
    it 'update sale price for inventory' do
      request.headers['Authorization'] = "Bearer #{u1.authentication_token}"
      patch :update, id: item1.id, inventory_item: inventory_item_price_params, format: :json
      expect(response.status).to eq 200
      expect(JSON.parse(response.body)['data']['id']).to eq item1.id
      expect(JSON.parse(response.body)['data']['sale_price']['amount']).to eq 200
      expect(JSON.parse(response.body)['data']['available_batches'].all? {|t| t['status'] == 'active'}).to eq true
    end
  end

end
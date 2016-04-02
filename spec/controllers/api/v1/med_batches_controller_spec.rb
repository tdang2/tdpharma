require 'rails_helper'

RSpec.describe Api::V1::MedBatchesController, type: :controller do
  include_context 'user params'
  include_context 'category params'
  include_context 'medicine params'
  include_context 'inventory item params'

  before do
    prepare_data
    u1.update!(store_id: s.id)
    item1.create_sale_price(amount: 100, discount: 0)
    item2.create_sale_price(amount: 150, discount: 0)
    item3
    request.headers['Authorization'] = "Bearer #{u1.authentication_token}"
  end

  describe 'GET index' do
    it 'get store med batches' do
      get :index, format: :json
      expect(response.status).to eq 200
      expect(JSON.parse(response.body)['data'].count).to be >= 3
      expect(JSON.parse(response.body)['data'].map{|i| i['inventory_item']['id']}).to include item1.id
      expect(JSON.parse(response.body)['data'].map{|i| i['medicine']['name']}).to include item2.itemable.name
      expect(JSON.parse(response.body)['data'].map{|i| i['category']['name']}).to include item3.category.name
    end

    it 'get store available batches only' do
      item2.med_batches.each {|b| b.update!(total_units: 0, number_pkg: 0)}
      get :index, format: :json
      expect(response.status).to eq 200
      expect(JSON.parse(response.body)['data'].count).to be >= 2
      expect(JSON.parse(response.body)['data'].map{|i| i['inventory_item']['id']}).not_to include item2.id
      expect(JSON.parse(response.body)['data'].map{|i| i['medicine']['name']}).not_to include item2.itemable.name
      expect(JSON.parse(response.body)['data'].map{|i| i['category']['name']}).not_to include item2.category.name
    end

    it 'get batches through barcode' do
      get :index, barcode: item1.med_batches.first.barcode, format: :json
      expect(response.status).to eq 200
      expect(JSON.parse(response.body)['data'].count).to eq 1
      expect(JSON.parse(response.body)['data'][0]['inventory_item']['id']).to eq item1.id
      expect(JSON.parse(response.body)['data'][0]['medicine']['name']).to eq item1.itemable.name
      expect(JSON.parse(response.body)['data'][0]['category']['name']).to eq item1.category.name
    end

    it 'get batches with barcode regardless empty or available batch' do
      item2.med_batches.each {|b| b.update!(total_units: 0, number_pkg: 0)}
      get :index, barcode: item2.med_batches.first.barcode, format: :json
      expect(JSON.parse(response.body)['data'].count).to eq 1
      expect(JSON.parse(response.body)['data'][0]['inventory_item']['id']).to eq item2.id
      expect(JSON.parse(response.body)['data'][0]['medicine']['name']).to eq item2.itemable.name
      expect(JSON.parse(response.body)['data'][0]['category']['name']).to eq item2.category.name
    end
  end


end
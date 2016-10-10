require 'rails_helper'

RSpec.describe Api::V1::MedicinesController, type: :controller do
  include_context 'user params'
  include_context 'category params'
  include_context 'medicine params'
  before do
    prepare_data
    u1.update!(store_id: s.id)
  end

  describe 'GET index' do
    it 'should return success' do
      u1.store.medicines << [med1, med2]
      get :index, format: :json, access_token: token.token
      expect(response.status).to eq 200
      expect(JSON.parse(response.body).count).to be >= 2
    end

    it 'checks search params' do
      u1.store.medicines << [med1, med2]
      get :index, by_name: 'med', format: :json, access_token: token.token
      expect(response.status).to eq 200
      expect(JSON.parse(response.body).count).to be >= 2
    end
  end

  describe 'POST create' do
    it 'create medicine and store inventory item' do
      post :create, medicine: med_params, format: :json, access_token: token.token
      mid = JSON.parse(response.body)['id']
      expect(response.status).to eq 200
      expect(JSON.parse(response.body)['itemable']['name']).to eq 'Claritin'
      expect(InventoryItem.find(mid).amount).to eq 1200
      expect(JSON.parse(response.body)['available_batches'].map{|b| b['receipt_id']}).to include(InventoryItem.find(mid).med_batches.first.receipt_id)
      expect(JSON.parse(response.body)['available_batches'].map{|b| b['receipt_id']}).to include(InventoryItem.find(mid).med_batches.last.receipt_id)
    end
    it 'medicine name must be titleize' do
      med_params['name'] = 'claritin light'
      post :create, medicine: med_params, format: :json, access_token: token.token
      expect(response.status).to eq 200
      expect(JSON.parse(response.body)['itemable']['name']).to eq 'Claritin Light'
    end
  end

  describe 'GET show' do
    it 'return requested medicine' do
      get :show, id: med1.id, format: :json, access_token: token.token
      expect(response.status).to eq 200
      expect(JSON.parse(response.body)['id']).to eq med1.id
    end
  end

  describe 'PATCH update' do
    it 'update medicine attributes' do
      patch :update, id: med1.id, medicine: med_params, format: :json, access_token: token.token
      expect(response.status).to eq 200
      expect(JSON.parse(response.body)['itemable']['name']).to eq 'Claritin'
    end
    it 'create an inventory item' do
      patch :update, id: med1.id, medicine: med_params, format: :json, access_token: token.token
      expect(s.inventory_items.where(itemable_type: 'Medicine', itemable_id: med1.id).count).to eq 1
    end
    it 'update existing inventory item' do
      create(:med_batch, category_id: c3.id, user: u1, store: s, medicine: med1, total_price: 200, total_units: 100)
      patch :update, id: med1.id, medicine: med_params, format: :json, access_token: token.token
      expect(s.inventory_items.where(itemable: med1).first.med_batches.count).to eq 3
    end
  end

  describe 'DELETE destroy' do
    it 'destroy the intended medicine' do
      create(:med_batch, category_id: c3.id, user: u1, store: s, medicine: med1, total_price: 200, total_units: 100)
      delete :destroy, id: med1.id, format: :json, access_token: token.token
      expect(response.status).to eq 200
      expect{Medicine.find(med1.id)}.to raise_error ActiveRecord::RecordNotFound
    end
  end

end
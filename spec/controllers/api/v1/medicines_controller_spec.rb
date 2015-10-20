require 'rails_helper'

RSpec.describe Api::V1::MedicinesController, type: :controller do
  include_context 'user params'
  include_context 'category params'
  include_context 'medicine params'
  before do
    prepare_data
    u1.update!(store_id: @s.id)
  end

  describe 'GET index' do
    it 'should return success' do
      med1
      med2
      sign_in u1
      get :index, email: u1.email, token: u1.authentication_token, format: :json
      expect(response.status).to eq 200
      expect(JSON.parse(response.body)['data'].count).to be >= 2
    end
  end

  describe 'POST create' do
    it 'create medicine and store inventory item' do
      sign_in u1
      post :create, email: u1.email, token: u1.authentication_token, medicine: med_params, format: :json
      expect(response.status).to eq 200
      expect(JSON.parse(response.body)['data']['name']).to eq 'Claritin'
    end
  end

  describe 'GET show' do
    it 'return requested medicine' do
      sign_in u1
      get :show, email: u1.email, token: u1.authentication_token, id: med1.id, format: :json
      expect(response.status).to eq 200
      expect(JSON.parse(response.body)['data']['id']).to eq med1.id
    end
  end

  describe 'PATCH update' do
    it 'update medicine attributes' do
      sign_in u1
      patch :update, email: u1.email, token: u1.authentication_token, id: med1.id, medicine: med_params, format: :json
      expect(response.status).to eq 200
      expect(JSON.parse(response.body)['data']['itemable']['name']).to eq 'Claritin'
    end
    it 'create an inventory item' do
      patch :update, email: u1.email, token: u1.authentication_token, id: med1.id, medicine: med_params, format: :json
      expect(@s.inventory_items.where(itemable_type: 'Medicine', itemable_id: med1.id).count).to eq 1
    end
    it 'update existing inventory item' do
      create(:med_batch, category_id: @c3.id, user: u1, store: @s, medicine: med1, total_price: 200, total_units: 100)
      patch :update, email: u1.email, token: u1.authentication_token, id: med1.id, medicine: med_params, format: :json
      expect(@s.inventory_items.where(itemable: med1).first.med_batches.count).to eq 3
    end
  end

  describe 'DELETE destroy' do
    it 'destroy the intended medicine' do
      create(:med_batch, category_id: @c3.id, user: u1, store: @s, medicine: med1, total_price: 200, total_units: 100)
      delete :destroy, email: u1.email, token: u1.authentication_token, id: med1.id, format: :json
      expect(response.status).to eq 200
      expect{Medicine.find(med1.id)}.to raise_error ActiveRecord::RecordNotFound
    end
  end

end
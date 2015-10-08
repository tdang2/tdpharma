require 'rails_helper'
require 'helpers/user_helper'
require 'helpers/category_helper'
require 'helpers/medicine_helper_spec'

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
    end
    it 'create an inventory item' do

    end
    it 'update existing inventory item' do

    end
  end

  describe 'DELETE destroy' do
    it 'destroy the intended medicine' do

    end
  end

end
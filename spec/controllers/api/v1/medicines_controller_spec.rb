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
      get :index, token: u1.authentication_token, format: :json
      expect(response.status).to eq 200
      expect(JSON.parse(response.body)['data'].count).to be >= 2
    end
  end

  describe 'POST create' do
    it 'create medicine and store inventory item' do
      sign_in u1
      post :create, token: u1.authentication_token, medicine: med_params, format: :json
      expect(response.status).to eq 200
      expect(JSON.parse(response.body)['data']['itemable']['name']).to eq 'Claritin'
    end
  end

  describe 'GET show' do

  end

  describe 'PATCH update' do

  end

  describe 'DELETE destroy' do

  end

end
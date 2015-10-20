require 'rails_helper'

RSpec.describe Api::V1::InventoryItemsController, type: :controller do
  include_context 'user params'
  include_context 'category params'
  include_context 'medicine params'
  let(:b1) {create(:med_batch, category_id: @c3.id, user: u1, store: @s, medicine: med1)}
  let(:b2) {create(:med_batch, category_id: @c2.id, user: u1, store: @s, medicine: med2)}
  let(:b3) {create(:med_batch, category_id: @c3.id, user: u1, store: @s, medicine: med3)}

  before do
    prepare_data
    u1.update!(store_id: @s.id)
    b1.inventory_item.create_sale_price(amount: 100, discount: 0)
    b2.inventory_item.create_sale_price(amount: 150, discount: 0)
    b3.inventory_item.update!(status: 'inactive')
  end

  describe 'GET index' do
    it 'should return active inventory items' do
      get :index, email: u1.email, token: u1.authentication_token, format: :json
      expect(response.status).to eq 200
      expect(JSON.parse(response.body)['data'].count).to be >= 2
      expect(JSON.parse(response.body)['data'].collect{|u| u['id']}).not_to include b3.inventory_item.id
      expect(JSON.parse(response.body)['data'].collect{|u| u['sale_price']}).not_to include nil
    end
    it 'should return inactive inventory items' do
      get :index, email: u1.email, token: u1.authentication_token, inactive: true, format: :json
      expect(response.status).to eq 200
      expect(JSON.parse(response.body)['data'].collect{|u| u['id']}).to include b3.inventory_item.id
      expect(JSON.parse(response.body)['data'].collect{|u| u['sale_price']}).to include nil
    end
  end

end
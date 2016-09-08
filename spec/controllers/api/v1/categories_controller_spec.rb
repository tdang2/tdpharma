require 'rails_helper'

RSpec.describe Api::V1::CategoriesController, type: :controller do
  include_context 'user params'
  include_context 'category params'
  before do
    prepare_data
    u1.update!(store_id: s.id)
  end

  describe 'GET index' do
    it 'return 400 error no store associated' do
      user =  create(:user, store: nil)
      t = create(:doorkeeper_access_token, resource_owner_id: user.id)
      get :index, access_token: t.token, format: :json
      expect(response.status).to eq 400
      expect(JSON.parse(response.body)['message']).to eq 'Current user has no associated store'
    end
    it 'return all categories' do
      get :index, access_token: token.token, format: :json
      expect(response.status).to eq 200
      expect(JSON.parse(response.body).count).to eq 2
      expect(JSON.parse(response.body)[0]['children'].count).to eq 2
    end
  end

  describe 'POST create' do
    it 'create and return all store categories' do
      post :create, category: category_params, access_token: token.token, format: :json
      expect(response.status).to eq 200
      # create and add to correct location
      expect(JSON.parse(response.body)[0]['children'][0]['children'].count).to eq 2
    end
  end

  describe 'PATCH update' do
    it 'update and return all store categories' do
      patch :update, id: c5.id, category: category_params, access_token: token.token, format: :json
      res = JSON.parse(response.body)[0]['children'][0]['children']
      expect(response.status).to eq 200
      expect(res.count).to eq 2                                           # Check switching parent correctly
      expect(res.find{|x| x['id'] == c5.id}['name']).to eq 'whatever'    # check updating attribute correctly
    end
  end

  describe 'GET show' do
    it 'return category and its children' do
      get :show, id: c3.id, access_token: token.token, format: :json
      expect(response.status).to eq 200
      expect(JSON.parse(response.body)['children'].count).to eq 1
    end
  end

  describe 'DELETE destroy' do
    it 'destroy and return store categories' do
      delete :destroy, id: c1.id, access_token: token.token, format: :json
      expect(response.status).to eq 200
      expect(JSON.parse(response.body).count).to eq 1
    end
    it 'destroy properly remove children categories' do
      delete :destroy, id: c1.id, access_token: token.token, format: :json
      s.reload
      expect(s.categories.to_a).to match_array [c2, c5]
    end
  end

end

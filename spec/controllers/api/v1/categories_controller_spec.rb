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
      sign_in user
      request.headers['Authorization'] = "Bearer #{user.authentication_token}"
      get :index, format: :json
      expect(response.status).to eq 400
      expect(JSON.parse(response.body)['data']['message']).to eq 'Current user has no associated store'
    end
    it 'return all categories' do
      sign_in u1
      request.headers['Authorization'] = "Bearer #{u1.authentication_token}"
      get :index, format: :json
      expect(response.status).to eq 200
      expect(JSON.parse(response.body)['authentication_token']).to eq u1.authentication_token
      expect(JSON.parse(response.body)['data'].count).to eq 2
      expect(JSON.parse(response.body)['data'][0]['children'].count).to eq 2
    end
  end

  describe 'POST create' do
    it 'create and return all store categories' do
      sign_in u1
      request.headers['Authorization'] = "Bearer #{u1.authentication_token}"
      post :create, category: category_params, format: :json
      expect(response.status).to eq 200
      expect(JSON.parse(response.body)['authentication_token']).to eq u1.authentication_token
      expect(JSON.parse(response.body)['data'][0]['children'][0]['children'].count).to eq 2   # create and add to correct location
    end
  end

  describe 'PATCH update' do
    it 'update and return all store categories' do
      sign_in u1
      request.headers['Authorization'] = "Bearer #{u1.authentication_token}"
      patch :update, id: c5.id, category: category_params, format: :json
      res = JSON.parse(response.body)['data'][0]['children'][0]['children']
      expect(response.status).to eq 200
      expect(res.count).to eq 2                                           # Check switching parent correctly
      expect(res.find{|x| x['id'] == c5.id}['name']).to eq 'whatever'    # check updating attribute correctly
    end
  end

  describe 'GET show' do
    it 'return category and its children' do
      sign_in u1
      request.headers['Authorization'] = "Bearer #{u1.authentication_token}"
      get :show, id: c3.id, format: :json
      expect(response.status).to eq 200
      expect(JSON.parse(response.body)['authentication_token']).to eq u1.authentication_token
      expect(JSON.parse(response.body)['data']['children'].count).to eq 1
    end
  end

  describe 'DELETE destroy' do
    it 'destroy and return store categories' do
      sign_in u1
      request.headers['Authorization'] = "Bearer #{u1.authentication_token}"
      delete :destroy, id: c1.id, format: :json
      expect(response.status).to eq 200
      expect(JSON.parse(response.body)['authentication_token']).to eq u1.authentication_token
      expect(JSON.parse(response.body)['data'].count).to eq 1
    end
    it 'destroy properly remove children categories' do
      sign_in u1
      request.headers['Authorization'] = "Bearer #{u1.authentication_token}"
      delete :destroy, id: c1.id, format: :json
      s.reload
      expect(s.categories.to_a).to match_array [c2, c5]
    end
  end

end

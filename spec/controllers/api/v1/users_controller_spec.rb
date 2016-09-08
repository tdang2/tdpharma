require 'rails_helper'

RSpec.describe Api::V1::UsersController, type: :controller do
  include_context 'user params'

  describe 'User authentication' do
    it 'must sign in' do
      get :show, id: u1.id, format: :json
      expect(response.status).to eq 401
      expect(response.header['WWW-Authenticate']).to eq "Bearer realm=\"Doorkeeper\", error=\"invalid_token\", error_description=\"The access token is invalid\""
    end
    it 'must provide authentication token' do
      sign_in u1
      get :show, id: u1.id, format: :json
      expect(response.status).to eq 401
      expect(response.header['WWW-Authenticate']).to eq "Bearer realm=\"Doorkeeper\", error=\"invalid_token\", error_description=\"The access token is invalid\""
    end
  end

  describe 'GET index' do
    it 'give list users' do
      get :index, access_token: token.token, format: :json
      expect(response.status).to eq 200
      expect(JSON.parse(response.body).all?{|u| u['photo_medium'].blank? == false}).to eq true
      expect(JSON.parse(response.body).count).to be > 1
    end
  end

  describe 'POST create' do
    it 'can not create new store user as employee' do
      post :create, user: users_full_params, access_token: token.token, format: :json
      expect(response.status).to eq 400
      expect(JSON.parse(response.body)['errors']).to eq 'You are not authorized to perform this action'
    end
    it 'can create new store user as manager' do
      t = create(:doorkeeper_access_token, resource_owner_id: u3.id)
      post :create, user: users_full_params, access_token: t.token, format: :json
      expect(response.status).to eq 200
      expect(JSON.parse(response.body)['first_name']).to eq 'tri'
      expect(JSON.parse(response.body)['store_id']).to eq s.id
    end
  end

  describe 'PATCH update' do
    it 'update user info' do
      patch :update, id: u1.id, user: users_patch_params, access_token: token.token, format: :json
      expect(response.status).to eq 200
      expect(JSON.parse(response.body)['photo_medium'].blank?).to eq false
      expect(JSON.parse(response.body)['first_name']).to eq 'trung'
      expect(JSON.parse(response.body)['last_name']).to eq 'dang2'
    end
    it 'update user role as manager' do
      t = create(:doorkeeper_access_token, resource_owner_id: u3.id)
      patch :update, id: u1.id, role_ids: [Role.first.id, role1.id], access_token: t.token, format: :json
      expect(response.status).to eq 200
      expect(JSON.parse(response.body)['roles'].any? {|r| r['name'] == Role.first.name}).to eq true
      expect(JSON.parse(response.body)['roles'].any? {|r| r['name'] == role1.name}).to eq true
    end
    it 'can not update user as employee' do
      patch :update, id: u1.id, user: users_patch_params, role_ids: [Role.first.id, role1.id], access_token: token.token, format: :json
      expect(JSON.parse(response.body)['roles'].any? {|r| r['name'] == role1.name}).to eq false
    end
  end

  describe 'GET show' do
    it 'get user info' do
      get :show, id: u1.id, access_token: token.token, format: :json
      expect(response.status).to eq 200
      expect(JSON.parse(response.body)['photo_medium'].blank?).to eq false
    end
    it 'get updated user info' do
      token
      Timecop.travel(DateTime.now + 36.hours)
      get :show, id: u1.id, access_token: token.token, format: :json
      expect(response.status).to eq 401
      expect(response.header['WWW-Authenticate']).to eq "Bearer realm=\"Doorkeeper\", error=\"invalid_token\", error_description=\"The access token expired\""
    end
  end

  describe 'GET destroy' do
    it 'can not destroy itself as employee' do
      delete :destroy, id: u1.id, access_token: token.token, format: :json
      expect(response.status).to eq 400
      expect(JSON.parse(response.body)['errors']).to eq 'You are not authorized to perform this action'
    end
    it 'can not destroy self as manager' do
      t = create(:doorkeeper_access_token, resource_owner_id: u3.id)
      delete :destroy, id: u3.id, access_token: t.token, format: :json
      expect(response.status).to eq 400
    end
    it 'destroy employee as manager' do
      t = create(:doorkeeper_access_token, resource_owner_id: u3.id)
      delete :destroy, id: u1.id, access_token: t.token, format: :json
      expect(response.status).to eq 200
      expect(User.all.include?(u1)).to eq false
    end
  end

end

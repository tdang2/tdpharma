require 'rails_helper'
require 'helpers/user_helper'

RSpec.describe Api::V1::UsersController, type: :controller do
  describe 'User authentication' do
    include_context 'user params'
    it 'must sign in' do
      get :show, id: u1.id, format: :json
      expect(response.status).to eq 401
    end
    it 'must provide authentication token' do
      sign_in u1
      get :show, id: u1.id, format: :json
      expect(response.status).to eq 401
    end
  end

  describe 'GET index' do
    include_context 'user params'
    it 'give list users' do
      sign_in u1
      get :index, token: u1.authentication_token, format: :json
      expect(response.status).to eq 200
      expect(JSON.parse(response.body).count).to be > 1
    end
  end

  describe 'PATCH update' do
    include_context 'user params'
    it 'update user info' do
      sign_in u1
      patch :update, id: u1.id, token: u1.authentication_token, user: users_patch_params, format: :json
      expect(response.status).to eq 200
      expect(JSON.parse(response.body)['first_name']).to eq 'trung'
      expect(JSON.parse(response.body)['last_name']).to eq 'dang2'
    end
    it 'update user role as manager' do
      sign_in u3
      patch :update, id: u1.id, token: u3.authentication_token, role_ids: [Role.first.id, role1.id], format: :json
      expect(response.status).to eq 200
      expect(JSON.parse(response.body)['roles'].any? {|r| r['name'] == Role.first.name}).to eq true
      expect(JSON.parse(response.body)['roles'].any? {|r| r['name'] == role1.name}).to eq true
    end
    it 'can not update user as employee' do
      sign_in u1
      patch :update, id: u1.id, token: u1.authentication_token, user: users_patch_params, role_ids: [Role.first.id, role1.id], format: :json
      expect(JSON.parse(response.body)['roles'].any? {|r| r['name'] == role1.name}).to eq false
    end
  end

  describe 'GET show' do
    include_context 'user params'
    it 'get user info' do
      sign_in u1
      get :show, id: u1.id, token: u1.authentication_token, format: :json
      expect(response.status).to eq 200
    end
    it 'get updated user info' do
      u1
      Timecop.travel(DateTime.now + 36.hours)
      sign_in u1
      get :show, id: u1.id, token: u1.authentication_token, format: :json
      expect(JSON.parse(response.body)['authentication_token']).not_to eq u1.authentication_token
    end
  end

  describe 'GET destroy' do
    include_context 'user params'
    it 'can not destroy itself as employee' do
      sign_in u1
      expect {delete :destroy, id: u1.id, token: u1.authentication_token, format: :json} .to raise_error CanCan::AccessDenied
    end
    it 'destroy itself as manager' do
      sign_in u3
      delete :destroy, id: u3.id, token: u3.authentication_token, format: :json
      expect(response.status).to eq 200
      expect(subject.current_user).to eq nil
      expect(User.all.include?(u3)).to eq false
    end
    it 'destroy employee as manager' do
      sign_in u3
      delete :destroy, id: u1.id, token: u3.authentication_token, format: :json
      expect(response.status).to eq 200
      expect(subject.current_user).to eq u3
      expect(User.all.include?(u1)).to eq false
    end
  end

end

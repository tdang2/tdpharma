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
      request.headers['Authorization'] = "#{u1.email}:#{u1.authentication_token}"
      get :index, format: :json
      expect(response.status).to eq 200
      expect(JSON.parse(response.body).count).to be > 1
    end
  end

  describe 'POST create' do
    include_context 'user params'
    it 'can not create new store user as employee' do
      sign_in u1
      request.headers['Authorization'] = "#{u1.email}:#{u1.authentication_token}"
      expect{post :create, user: users_full_params, format: :json} .to raise_error CanCan::AccessDenied
    end
    it 'can create new store user as manager' do
      sign_in u3      
      request.headers['Authorization'] = "#{u3.email}:#{u3.authentication_token}"
      post :create, user: users_full_params, format: :json
      expect(response.status).to eq 200
      expect(JSON.parse(response.body)['data']['first_name']).to eq 'tri'
      expect(JSON.parse(response.body)['data']['store_id']).to eq s.id
    end
  end

  describe 'PATCH update' do
    include_context 'user params'
    it 'update user info' do
      sign_in u1
      request.headers['Authorization'] = "#{u1.email}:#{u1.authentication_token}"
      patch :update, id: u1.id, user: users_patch_params, format: :json
      expect(response.status).to eq 200
      expect(JSON.parse(response.body)['first_name']).to eq 'trung'
      expect(JSON.parse(response.body)['last_name']).to eq 'dang2'
    end
    it 'update user role as manager' do
      sign_in u3      
      request.headers['Authorization'] = "#{u3.email}:#{u3.authentication_token}"
      patch :update, id: u1.id, role_ids: [Role.first.id, role1.id], format: :json
      expect(response.status).to eq 200
      expect(JSON.parse(response.body)['roles'].any? {|r| r['name'] == Role.first.name}).to eq true
      expect(JSON.parse(response.body)['roles'].any? {|r| r['name'] == role1.name}).to eq true
    end
    it 'can not update user as employee' do
      sign_in u1
      request.headers['Authorization'] = "#{u1.email}:#{u1.authentication_token}"
      patch :update, id: u1.id, user: users_patch_params, role_ids: [Role.first.id, role1.id], format: :json
      expect(JSON.parse(response.body)['roles'].any? {|r| r['name'] == role1.name}).to eq false
    end
  end

  describe 'GET show' do
    include_context 'user params'
    it 'get user info' do
      sign_in u1
      request.headers['Authorization'] = "#{u1.email}:#{u1.authentication_token}"
      get :show, id: u1.id, format: :json
      expect(response.status).to eq 200
    end
    it 'get updated user info' do
      u1
      Timecop.travel(DateTime.now + 36.hours)
      sign_in u1
      request.headers['Authorization'] = "#{u1.email}:#{u1.authentication_token}"
      get :show, id: u1.id, format: :json
      expect(JSON.parse(response.body)['authentication_token']).not_to eq u1.authentication_token
    end
  end

  describe 'GET destroy' do
    include_context 'user params'
    it 'can not destroy itself as employee' do
      sign_in u1
      request.headers['Authorization'] = "#{u1.email}:#{u1.authentication_token}"
      expect {delete :destroy, id: u1.id, format: :json} .to raise_error CanCan::AccessDenied
    end
    it 'destroy itself as manager' do
      sign_in u3
      request.headers['Authorization'] = "#{u3.email}:#{u3.authentication_token}"      
      delete :destroy, id: u3.id, format: :json
      expect(response.status).to eq 200
      expect(subject.current_user).to eq nil
      expect(User.all.include?(u3)).to eq false
    end
    it 'destroy employee as manager' do
      sign_in u3
      request.headers['Authorization'] = "#{u3.email}:#{u3.authentication_token}"      
      delete :destroy, id: u1.id, format: :json
      expect(response.status).to eq 200
      expect(subject.current_user).to eq u3
      expect(User.all.include?(u1)).to eq false
    end
  end

end

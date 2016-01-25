require 'rails_helper'
require 'helpers/user_helper'

RSpec.describe Users::SessionsController, type: :controller do
  describe 'Sign in User' do
    include_context 'user params'
    before do
      u1    # create user 1
    end

    it 'should sign in user as json' do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      post :create, user: user_sign_in_params, :format => :json
      expect(response.status).to eq 201
      expect(JSON.parse(response.body)['email']).to eq u1.email
      expect(JSON.parse(response.body)['authentication_token']).not_to eq nil
      expect(JSON.parse(response.body)['last_checked_in']).to be_between(DateTime.now - 2.seconds, DateTime.now + 2.seconds)
    end
  end

  describe 'Sign out User' do
    include_context 'user params'
    it 'should sign out user as json' do
      @request.env['devise.mapping'] = Devise.mappings[:user]
      sign_in u1
      delete :destroy, :format => :json
      expect(response.status).to eq 200
      expect(JSON.parse(response.body)['message']).to eq 'Log out successfully'
    end
    it 'should sign out after sign in as json' do
      u1
      @request.env['devise.mapping'] = Devise.mappings[:user]
      post :create, user: user_sign_in_params, :format => :json
      delete :destroy, :format => :json
      expect(response.status).to eq 200
      expect(subject.current_user).to eq nil
    end
  end
end
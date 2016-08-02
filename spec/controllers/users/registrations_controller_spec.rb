require 'rails_helper'

RSpec.describe Users::RegistrationsController, type: :controller do
  describe 'Sign up Users' do
    let(:user_params) do
      {
          email: 'tdang2@babson.edu',
          password: 'password',
          first_name: 'Tri',
          last_name: 'Dang'
      }
    end
    it 'should sign up users as json' do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      post :create, user: user_params, :format => :json
      expect(response.status).to eq 201
      expect(JSON.parse(response.body)['photo_medium'].blank?).to eq false
    end
  end
end
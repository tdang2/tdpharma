require 'rails_helper'

RSpec.describe Api::V1::ConfigurationsController, type: :controller do
  include_context 'user params'

  describe 'GET show' do
    it 'return amazon temp s3 config' do
      sign_in u1
      request.headers['Authorization'] = "#{u1.email}:#{u1.authentication_token}"
      get :show, id: 'temp_amazon_s3', format: :json
      expect(response.status).to eq 200
      expect(JSON.parse(response.body)['authentication_token']).to eq u1.authentication_token
      expect(JSON.parse(response.body)['data']['aws_access_key_id']).not_to eq nil
      expect(JSON.parse(response.body)['data']['aws_secret_access_key']).not_to eq nil
      expect(JSON.parse(response.body)['data']['aws_region']).not_to eq nil
      expect(JSON.parse(response.body)['data']['bucket_name']).not_to eq nil
    end
  end
end

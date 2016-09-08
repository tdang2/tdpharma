require 'rails_helper'

RSpec.describe Api::V1::ConfigurationsController, type: :controller do
  include_context 'user params'

  describe 'GET show' do
    it 'return amazon temp s3 config' do
      get :show, id: 'temp_amazon_s3', access_token: token.token, format: :json
      expect(response.status).to eq 200
      expect(JSON.parse(response.body)['aws_access_key_id']).not_to eq nil
      expect(JSON.parse(response.body)['aws_secret_access_key']).not_to eq nil
      expect(JSON.parse(response.body)['aws_region']).not_to eq nil
      expect(JSON.parse(response.body)['bucket_name']).not_to eq nil
    end
  end
end

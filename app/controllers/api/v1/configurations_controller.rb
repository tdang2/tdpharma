class Api::V1::ConfigurationsController < Api::ApiController
  before_action :doorkeeper_authorize!

  def show
    if params[:id] == 'temp_amazon_s3'
      config = {
          aws_access_key_id: ENV['AWS_ACCESS_KEY_ID'],
          aws_secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
          aws_region: ENV['S3_REGION'],
          bucket_name: ENV['S3_PUBLIC_BUCKET']
      }
      render json: config.as_json, status: 200
    end
  end

end

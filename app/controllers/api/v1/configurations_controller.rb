class Api::V1::ConfigurationsController < ApplicationController
  before_filter :authenticate_user!             # standard devise web app

  def show
    begin
      if params[:id] == 'temp_amazon_s3'
        config = {
            aws_access_key_id: ENV['AWS_ACCESS_KEY_ID'],
            aws_secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
            aws_region: ENV['S3_REGION'],
            bucket_name: ENV['S3_PUBLIC_BUCKET']
        }
        render json: prepare_json(config.as_json), status: 200
      end
    rescue StandardError => e
      render json: prepare_json({errors: e.message}), status: 400
    end
  end

end

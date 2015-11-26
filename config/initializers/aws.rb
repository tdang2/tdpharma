require 'aws-sdk'

Aws.config.update({region: ENV['S3_REGION'], credentials: Aws::Credentials.new(ENV['AWS_ACCESS_KEY_ID'], ENV['AWS_SECRET_ACCESS_KEY'])})

S3_BUCKET = Aws::S3::Resource.new.bucket(ENV['S3_BUCKET_NAME'])
S3_PUBLIC_BUCKET = Aws::S3::Resource.new.bucket(ENV['S3_PUBLIC_BUCKET'])
S3_PUBLIC_CLIENT = Aws::S3::Client.new(region: ENV['S3_REGION'])
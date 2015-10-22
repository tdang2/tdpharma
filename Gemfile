source 'https://rubygems.org'

ruby "2.2.3"

gem 'airbrake'
gem 'awesome_nested_set'
gem 'clockwork'
gem 'delayed_job_active_record'
gem 'email_validator'
gem 'flutie'
gem 'high_voltage'
gem 'cancancan'
gem 'ice_cube'
gem 'protected_attributes'
gem 'kaminari'
gem 'pg'
gem 'geocoder'
gem 'rack-cors', :require => 'rack/cors'
gem 'rack-timeout'
gem 'recipient_interceptor'
gem 'title'
gem 'activeadmin', github: 'activeadmin'
gem 'devise'
gem 'devise_security_extension', :git => 'https://github.com/phatworx/devise_security_extension.git'
gem 'autoprefixer-rails'
gem 'paperclip', '~> 4.2'
gem 'aws-sdk', '~> 2'
gem 'aws-sdk-v1'            # Need this for paperclip Jul-14-2015
gem 'workflow'
gem 'mailboxer', :git => 'git://github.com/div/mailboxer.git', :branch => 'rails42-foreigner'
gem 'lazy_high_charts'
gem 'rails', '~> 4.2.1'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.1.0'
gem 'jquery-rails'
gem 'turbolinks'
gem 'sdoc', '~> 0.4.0', group: :doc
gem 'puma'


# Frontend asset
gem "messengerjs-rails", "~> 1.4.1"
gem 'jquery-datatables-rails', '~> 3.1.1'

group :development, :test do
  gem 'byebug'
  gem 'web-console', '~> 2.0'
  gem 'spring'
  gem "dotenv-rails"
  gem "awesome_print"
  gem "factory_girl_rails"
  gem 'rspec-rails', '~> 3.0'
  gem "pry-rails"
end

group :development do
  gem 'letter_opener'
  gem 'quiet_assets'
  gem "foreman"
end

group :test do
  #gem 'capybara-webkit'
  gem "capybara-angular"
  gem 'selenium-webdriver'
  gem "database_cleaner"
  gem "formulaic"
  gem "launchy"
  gem "shoulda-matchers", '~> 3.0'
  gem "timecop"
  gem "webmock"
end

group :staging, :production do
  gem "newrelic_rpm", ">= 3.7.3"
end



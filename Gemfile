source 'https://rubygems.org'

ruby "2.2.3"

gem 'airbrake', '~> 4.3'
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
gem 'paperclip'
gem 'aws-sdk', '~> 2'
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
gem 'less-rails'
gem 'therubyracer' # Ruby - dependency for less rails
gem 'therubyrhino' # JRuby - dependency for less rails
gem 'routing-filter'
gem 'sprockets', '2.12.3' # require for rails angular template
gem 'paper_trail'
gem 'has_scope'


# Frontend asset
gem 'jquery-datatables-rails', '~> 3.1.1'
gem 'yui-compressor', '~> 0.12.0'
gem 'jade'
gem 'angular-rails-templates'
source 'https://rails-assets.org' do
  gem 'rails-assets-angular'
  gem 'rails-assets-angular-bootstrap'
  gem 'rails-assets-angular-cookies'
  gem 'rails-assets-angular-resource'
  gem 'rails-assets-angular-sanitize'
  gem 'rails-assets-angular-smart-table'
  gem 'rails-assets-angular-socket-io'
  gem 'rails-assets-angular-translate'
  gem 'rails-assets-angular-ui-router'
  gem 'rails-assets-async'
  gem 'rails-assets-aws-sdk'
  gem 'rails-assets-bootstrap'
  gem 'rails-assets-es5-shim'
  gem 'rails-assets-fontawesome'
  gem 'rails-assets-json3'
  gem 'rails-assets-lodash'
  gem 'rails-assets-moment'
  gem 'rails-assets-ng-file-upload'
  gem 'rails-assets-toastr'
  gem 'rails-assets-underscore'
  gem 'rails-assets-angular-ui'
  gem 'rails-assets-angular-ui-select'
end

group :development, :test do
  gem 'byebug'
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
  gem 'web-console', '~> 2.0'
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
  gem 'rails_12factor'
end



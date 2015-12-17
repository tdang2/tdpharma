require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Pharma
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    config.autoload_paths += Dir[Rails.root.join('app', 'models', '{**/}')]
    config.assets.paths << Rails.root.join('vendor', 'assets', 'components')

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :vn

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true

    config.active_job.queue_adapter = :delayed_job

    # Set up amazon s3 and paperclip
    config.paperclip_defaults = {
        :storage => :s3,
        :s3_credentials => {
            :bucket => ENV['S3_BUCKET_NAME'],
            :access_key_id => ENV['AWS_ACCESS_KEY_ID'],
            :secret_access_key => ENV['AWS_SECRET_ACCESS_KEY']
        },
        :url =>':s3_domain_url',                                    # Need these to get correct end point
        :path => ':class/:attachment/:id/:style/:filename',         # Need these to get correct end point
    }

    config.action_mailer.asset_host = ENV["ASSET_HOST"]
    config.action_mailer.default_url_options = { host: ENV["ASSET_HOST"] }

    config.middleware.insert_before 0, "Rack::Cors", :debug => true, :logger => (-> { Rails.logger }) do
      allow do
        origins '*'

        resource '/cors',
                 :headers => :any,
                 :methods => [:post],
                 :credentials => true,
                 :max_age => 0

        resource '*',
                 :headers => :any,
                 :methods => [:get, :post, :delete, :put, :patch, :options, :head],
                 :max_age => 0
      end
    end

    # Set up generators
    config.generators do |generate|
      generate.test_framework :rspec
      generate.fixture_replacement :factory_girl
    end

  end
end

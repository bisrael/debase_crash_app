require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

unless Rails.env.production?
# no sandbox environment for roadstruck svb exists; stub it out
# so that we can do some testing
  require 'webmock'
  include WebMock::API

  # allow all connections, exception to roadstruck-svb
  WebMock.enable!
  WebMock.disable_net_connect!(allow: lambda {|uri|
    uri.host.exclude?('api.example.com')
  })

  stub_request(:post, "https://api.example.com/v1/virtualcards").to_return(status: 200,
    body: lambda {|request|
      # return the same amount as was requested, so that we don't think something is wrong.
      resp = {
        "status" => "Approved",
        "available_balance" => ActiveSupport::JSON.decode(request.body)['data']['total_card_amount'],
        "card_number" => "4242424242424242",
        "expiry" => "2018-01",
        "cvc" => "111"
      }
      {data: resp}.to_json
    })
end

module DebaseCrashApp
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true
  end
end

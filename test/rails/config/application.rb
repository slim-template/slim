require File.expand_path('../boot', __FILE__)

require 'active_model/railtie'
require 'action_controller/railtie'
require 'action_view/railtie'
#require 'active_record/railtie'
#require 'action_mailer/railtie'
require "sprockets/railtie"

require 'slim'

module Dummy
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # JavaScript files you want as :defaults (application.js is always included).
    # config.action_view.javascript_expansions[:defaults] = %w(jquery rails)

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # From slim-rails fix for "ActionView::Template::Error: Unknown line indicator"
    # https://github.com/slim-template/slim-rails/blob/991589ea5648e5e896781e68912bc51beaf4102a/lib/slim-rails/register_engine.rb
    if config.respond_to?(:assets)
      config.assets.configure do |env|
        if env.respond_to?(:register_transformer) && Sprockets::VERSION.to_i > 3
          env.register_mime_type 'text/slim', extensions: ['.slim', '.slim.html']
          env.register_transformer 'text/slim', 'text/html', RegisterEngine::Transformer
        elsif env.respond_to?(:register_engine)
          args = ['.slim', Slim::Template]
          args << { silence_deprecation: true } if Sprockets::VERSION.start_with?('3')
          env.register_engine(*args)
        end
      end
    end
  end
end

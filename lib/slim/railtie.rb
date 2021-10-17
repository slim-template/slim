module Slim
  class Railtie < Rails::Railtie
    initializer "initialize slim template handler" do
      ActiveSupport.on_load(:action_view) do
        require "slim/rails_template"
      end
    end
  end
end

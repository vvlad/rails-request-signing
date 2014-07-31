# This file is copied to spec/ when you run 'rails generate rspec:install'
$: << File.expand_path("../../lib", __FILE__)
ENV["RAILS_ENV"] ||= 'test'

require 'rails/all'
require 'rspec/rails'

require 'rails/request/signing'

ActiveRecord::Base.establish_connection adapter: "sqlite3", database: ":memory:"

module Rails::Request::Signing
  class Application < Rails::Application

    config.action_controller.action_on_unpermitted_parameters = :raise
    config.secret_key_base = 'a-secret-key'

  end
end

RSpec.configure do |config|



  config.mock_with :rspec
  config.infer_base_class_for_anonymous_controllers = false
  config.order = "random"

  config.filter_run focus: true
  config.run_all_when_everything_filtered = true

end

ActionView::TestCase::TestController.instance_eval do
  helper Rails.application.routes.url_helpers#, (append other helpers you need)
end
ActionView::TestCase::TestController.class_eval do
  def _routes
    Rails.application.routes
  end
end

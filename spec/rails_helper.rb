# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../config/environment.rb', __dir__)
abort('The Rails environment is running in production mode!') if Rails.env.production?

require 'spec_helper'
require 'rspec/rails'

require 'factory_bot_rails'
require 'faker'
require 'devise'

ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  config.include Devise::Test::IntegrationHelpers
  config.include Warden::Test::Helpers

  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include Devise::Test::ControllerHelpers, type: :view

  config.before(:suite) do
    Warden.test_mode!
  end

  config.before(:each) do
    Devise.mappings[:user] = Devise.mappings[:user] || Devise::Mapping.new(:user, {})
  end

  config.after(:each) do
    Warden.test_reset!
  end

  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!

  config.include FactoryBot::Syntax::Methods

  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each, js: true) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

  # Configure ActiveJob to use test adapter
  config.before(:each) do
    ActiveJob::Base.queue_adapter = :test
  end
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end

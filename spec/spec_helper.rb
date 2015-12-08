require 'simplecov'
require 'coveralls'

SimpleCov.start 'rails' do
  add_filter '/spec/'
  add_filter '/vendor/'
  add_group 'Controllers', 'app/controllers'
  add_group 'Helpers', 'app/helpers'
  add_group 'Jobs', 'app/jobs'
  add_group 'Models', 'app/models'
  add_group 'Library', 'lib'
end

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
]
SimpleCov.minimum_coverage 100
SimpleCov.refuse_coverage_drop

require 'database_cleaner'

# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'capybara/rspec'
require 'capybara/poltergeist'
require 'capybara-screenshot/rspec'
require 'rspec/rails'
require 'vcr'
require 'devise'
require 'cancan/matchers'
include Warden::Test::Helpers

Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

VCR.configure do |c|
  c.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  c.hook_into :webmock
  c.configure_rspec_metadata!
  c.ignore_localhost = true
end

Capybara.default_selector = :css
Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, window_size: [1920, 1080], phantomjs_logger: nil)
end
Capybara.javascript_driver = :poltergeist
Capybara.default_max_wait_time = 30
# Capybara.register_driver :selenium do |app|
#   Capybara::Selenium::Driver.new(app, browser: :chrome)
# end

RSpec.configure do |config|
  config.include Devise::TestHelpers, type: :controller
  config.include ApplicationHelper
  config.mock_with :rspec do |c|
    c.syntax = [:should, :expect]
  end
  config.expect_with :rspec do |c|
    c.syntax = [:should, :expect]
  end

  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  config.use_transactional_fixtures = false

  config.infer_base_class_for_anonymous_controllers = false

  config.order = 'random'

  config.before(:suite) do
    DatabaseCleaner[:active_record].strategy = :deletion
    DatabaseCleaner.clean_with(:truncation)
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
end

class ApplicationController < ActionController::Base
  if Rails.env.test?
    rescue_from ActionController::InvalidCrossOriginRequest do
      render_404 unless Rails.application.config.consider_all_requests_local
    end
  end
end

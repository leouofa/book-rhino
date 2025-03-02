source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.3.0"

gem 'rails', '~> 8.0'
gem "puma", "~> 6.0"

# Core
gem 'awesome_print'
gem 'fancy_irb'
gem "bootsnap", require: false
gem 'canonical-rails', github: 'jumph4x/canonical-rails'
gem 'config'
gem 'deep_cloneable', '~> 3.2.0'
gem 'friendly_id'
gem 'httparty'
gem 'maruku'
gem 'reverse_markdown'
gem 'jsonb_accessor'
gem "jbuilder"
gem 'rack-canonical-host'
gem 'ruby-openai'
gem 'rexml'
gem 'paper_trail'

# Database
gem 'hiredis'
gem "pg", "~> 1.1"
gem 'redis'
gem 'sidekiq'
gem 'neighbor'

# Authentication
gem 'devise'
gem 'devise-tailwindcssed', github: 'leouofa/devise-tailwindcssed', branch: 'version_bump'

# Pagination
gem 'kaminari', github: 'kaminari/kaminari', branch: 'master'

# Frontend
gem 'meta-tags'
gem 'rapid_ui', github: 'leouofa/rapid-ui'
gem 'simple_form'
gem 'slim-rails'
gem 'sprockets-rails'
gem "stimulus-rails"
gem 'turbo-rails'
gem 'view_component'
gem 'vite_rails'
gem 'redcarpet'

# Middleware
gem 'rack-attack'
gem 'rack-cors'

group :development, :test do
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'dotenv-rails'
  gem 'rubocop'
  gem 'rubocop-rails'
  gem 'tty-prompt'
  gem 'webmock'
end

group :development do
  gem "web-console"
  gem 'annotaterb'
  gem 'foreman'
end

group :test do
  gem 'capybara'
  gem 'database_cleaner'
  gem 'faker'
  gem 'factory_bot_rails'
  gem 'rack_session_access'
  gem 'rails-controller-testing'
  gem 'rspec-rails'
  gem 'rspec_tap', require: false
  gem 'timecop'
  gem 'selenium-webdriver'
  gem 'shoulda-matchers', '~> 5.0'
  gem 'webdrivers'
end


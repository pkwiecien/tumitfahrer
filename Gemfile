source 'https://rubygems.org'
ruby '2.0.0'

# gem for the development and production environment.
gem 'rails', '~> 4.0.4'
# contains custom css elements
gem "bootstrap-sass", "~> 3.1.0.2"
# used to encrypt passwords
gem 'bcrypt-ruby', '~> 3.1.2'
# paginates large results
gem "will_paginate", "~> 3.0.5"
# paginates large results with bootstrap style
gem "bootstrap-will_paginate", "~> 0.0.10"
# gem for push notificaitons to Android devices
gem 'push-gcm'
# gem for push notificaitons to Android devices
gem 'gcm', :require => "gcm"
# gem for push notificaitons to iOS devices
gem 'grocer'
# gem for push notificaitons to iOS devices
gem 'houston', '~> 2.0.2', :require => 'houston'
# used for parsing xml requests
gem 'actionpack-xml_parser'
#gem "paperclip", "~> 4.1"
gem "httparty", "~> 0.13.0"
# for application monitoring
gem 'newrelic_rpm'

group :development, :production do
  # postgres database
  # gem 'pg', '0.15.1'
  gem 'mysql2'
  gem 'rails_12factor', '0.0.2'
end

group :development do
  # test framework used for TDD
  gem 'rspec-rails', '2.13.1'
end

group :test do
  gem 'selenium-webdriver', '2.35.1'
  gem 'capybara', '2.1.0'
  gem "sqlite3", "~> 1.3.8"
end

group :development, :test do
  gem 'railroady'
end

# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.0'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0.0'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
gem 'execjs'
gem 'therubyracer', :platforms => :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'

gem 'therubyracer'
#gem 'angularjs-rails'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 1.2'

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

gem 'active_model_serializers'

# Use unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano', group: :development

# Use debugger
# gem 'debugger', group: [:development, :test]

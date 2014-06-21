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
gem "httparty", "~> 0.13"
# for application monitoring
gem 'newrelic_rpm'
# for getting location
gem "geocoder"

# gem 'ruby-debug-ide'
#gem 'linecache','0.46'
#gem 'ruby-debug-base19x'
 # gem 'linecache19', '>= 0.5.13', :git => 'https://github.com/robmathews/linecache19-0.5.13.git'
# gem 'ruby-debug-base19x', '0.11.30.pre10'
# gem 'ruby-debug-ide', '0.4.17.beta14'
gem "debase"
gem 'nifty-generators'

gem 'gmaps4rails'
group :development, :production do
  # postgres database
<<<<<<< HEAD
  gem 'mysql2'
=======
  #gem 'pg', '0.15.1'
>>>>>>> b2b59b3f985142e3b9fb11ed48780811a44bffbc
  gem 'rails_12factor', '0.0.2'
  gem 'mysql2'

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

#gem 'angularjs-rails'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
#gem 'turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 1.2'

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

gem 'active_model_serializers'
# for storing images
gem 'paperclip'
gem 'aws-sdk'

# Use unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano', group: :development

# Use debugger
# gem 'debugger', group: [:development, :test]

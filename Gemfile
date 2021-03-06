source 'https://rubygems.org'

gem 'rails', '4.2.1'
gem 'russian'

# DB
gem 'pg'

# pagination
gem 'kaminari'
gem 'kaminari-bootstrap', '~> 3.0.1'
gem 'kaminari-i18n'
# validate dates
gem 'date_validator'

# views
gem 'haml'
gem 'haml-rails'

# authentication
gem 'devise', '~> 3.4.0'

# CSS
# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.0'
# font awesome icons
gem 'font-awesome-rails'

gem 'compass-rails'

# JS
# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0.0'
# Use jquery as the JavaScript library
gem 'jquery-rails'
# jquery UI
gem 'jquery-ui-rails', '~> 4.2.1'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
gem 'therubyracer', platforms: :ruby
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# chosen js library
gem 'chosen-rails'
# AngularJS magic framework
gem 'angularjs-rails'
gem 'angular-ui-bootstrap-rails', '0.10.0'
gem 'angularjs-rails-resource', '~> 1.0.0'
# File upload
gem 'jquery-fileupload-rails', github: 'Springest/jquery-fileupload-rails'
# Jcrop library for cropping images before upload
gem 'jcrop-rails-v2'

# other
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 1.2'

# app server
gem 'puma'

# docx
gem 'rubyzip'
gem 'docx_rails', github: 'altmer/docx-rails'
gem 'zip-zip' # will load compatibility for old rubyzip API.

# redis for in-memory store
gem 'hiredis'
gem 'redis', :require => ["redis", "redis/connection/hiredis"]

# image uploading
gem 'dragonfly'
gem 'dragonfly-s3_data_store'

# caching
gem 'dalli'

# production caching
group :production do
  gem 'rack-cache', :require => 'rack/cache'
end

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

group :development do
  # Use Capistrano for deployment
  gem 'capistrano', '~> 3.1.0'
  gem 'capistrano-rails',   '~> 1.1', require: false
  gem 'capistrano-bundler', '~> 1.1', require: false
  gem 'capistrano-rvm',   '~> 0.1', require: false

  # show errors
  gem 'better_errors'
  gem 'binding_of_caller'
end

# tests
group :test do
  # BDD unit testing
  gem 'rspec', '~> 3.1'
  gem 'rspec-rails', '~> 3.1'
  gem 'fuubar', '~> 2.0.0.rc1', require: false

  # BDD integration testing
  gem 'minitest'
  gem 'cucumber'
  gem 'cucumber-rails', require: false
  gem 'database_cleaner'

  # matchers for tests
  gem 'shoulda-matchers'
  # time stubs and mocks
  gem 'timecop'
  # test data fixtures
  gem 'factory_girl'
  gem 'factory_girl_rails'
  # integration test (selenium)
  gem 'capybara'

  # test email
  gem 'email_spec'
  # launching cross-platform applications in a fire and forget manner
  gem 'launchy'
end
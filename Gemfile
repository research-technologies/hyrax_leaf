source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.0'
# Use sqlite3 as the database for Active Record
gem 'sqlite3'
# Use Puma as the app server
gem 'puma', '~> 4.3.12'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'web-console', '>= 3.3.0'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

gem 'hyrax', '~> 3.1'
# rdf 3.2.5 conflicts with a monkey patch in acive-fedora 13.2.5 and below
gem 'rdf', '~> 3.2', '<= 3.2.4'
gem 'okcomputer', '~> 1.6', '>= 1.6.4'

#gem 'hyrax', '~> 2.9', '>= 2.9.3'

#gem 'hyrax', '~> 2.5'

group :development, :test do
  gem 'easy_translate'
  gem 'fcrepo_wrapper'
  gem 'i18n-tasks'
  gem 'solr_wrapper', '>= 0.3'
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '~> 2.13'
  gem 'selenium-webdriver'
  gem 'rspec-rails'
end

gem 'devise'
gem 'devise-guests', '~> 0.6'
gem 'jquery-rails'
gem 'rsolr', '>= 1.0'

gem 'riiif', '~> 2.0'

#gem 'dog_biscuits'
gem 'dog_biscuits', git: 'https://github.com/research-technologies/dog_biscuits.git'
gem 'hydra-role-management'
gem 'leaf_addons', git: 'https://github.com/research-technologies/leaf_addons.git'
gem 'pg', '~> 0.21.0'
gem 'sidekiq'

# Blacklight Range Limit
gem 'blacklight_range_limit', '~> 7.0.0'

gem 'browse-everything', '< 1.0.0'

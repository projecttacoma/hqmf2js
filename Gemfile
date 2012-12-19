source "http://rubygems.org"

gem 'rails', '3.2.9'

group :assets do
  gem 'sass-rails'
  gem 'coffee-rails'
  gem 'uglifier'
end

gem "hquery-patient-api", '~> 1.0.0'
gem 'hqmf-parser', '~> 1.1.0'
gem "health-data-standards", '~> 2.2.0'

gem 'nokogiri'
gem 'sprockets', '~> 2.2.2'
gem 'coffee-script'
gem 'uglifier'
gem 'tilt'
gem 'rake'
gem 'pry'

group :test do
  gem 'minitest'
  gem 'turn', :require => false
  gem 'cover_me', '~> 1.2.0'
  gem 'awesome_print', :require => 'ap'
  
  platforms :ruby do
    gem "therubyracer", :require => 'v8'
  end
  
  platforms :jruby do
    gem "therubyrhino"
  end
end

source "http://rubygems.org"

gem 'rails', '3.2.9'

group :assets do
  gem 'sass-rails'
  gem 'coffee-rails'
  gem 'uglifier'
end

gem 'hquery-patient-api', :git => 'https://github.com/pophealth/patientapi.git', :branch => 'develop'
#gem 'hquery-patient-api', :path => '../patientapi'
gem 'health-data-standards', :git => 'https://github.com/projectcypress/health-data-standards.git', :branch => 'develop'
#gem 'health-data-standards', :path => '../health-data-standards'

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

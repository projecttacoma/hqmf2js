source "http://rubygems.org"

gem 'rails'

group :assets do
  gem 'sass-rails'
  gem 'coffee-rails'
  gem 'uglifier'
end

#gem "hquery-patient-api", :git => 'http://github.com/pophealth/patientapi.git', :branch => 'develop'
#gem 'hquery-patient-api', :path => '../patientapi'
gem 'hquery-patient-api', '~> 0.3.0'
gem 'hqmf-parser', :git => 'https://github.com/pophealth/hqmf-parser.git', :branch => 'develop'
#gem 'hqmf-parser', :path => '../hqmf-parser'
#gem 'hqmf-parser', '~> 1.0.2'
#gem "health-data-standards", :git => 'http://github.com/projectcypress/health-data-standards.git', :branch => 'develop'
gem "health-data-standards", '~> 2.1.2'

gem 'nokogiri'
gem 'sprockets'
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

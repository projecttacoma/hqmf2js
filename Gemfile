source "https://rubygems.org"

gem 'rails', '~> 4.2.7'

group :assets do
  gem 'sass-rails'
  gem 'coffee-rails'
end

gem 'hquery-patient-api', :git => 'https://github.com/projecttacoma/patientapi.git', :branch => 'master'
#gem 'hquery-patient-api', :path => '../patientapi'
# will point HDS to mongoid5 after nokogiri fix applied (before merging this hqmf2js PR)
#gem 'health-data-standards', :git => 'https://github.com/projectcypress/health-data-standards.git', :branch => 'mongoid5'
gem 'health-data-standards', :git => 'https://github.com/projectcypress/health-data-standards.git', :branch => 'bonnie-prior_1302_nokogiri_fix'
#gem 'health-data-standards', :path => '../health-data-standards'

gem 'nokogiri', '~> 1.8.2'
gem 'sprockets'
gem 'coffee-script'
gem 'uglifier'
gem 'tilt'
gem 'rake'
gem 'pry'

group :test, :ci do
  gem 'simplecov', :require => false

  gem 'minitest'
  gem 'turn', :require => false
  gem 'awesome_print', :require => 'ap'
  gem 'bundler-audit'
  
  platforms :ruby do
    gem "therubyracer", :require => 'v8'
  end
end

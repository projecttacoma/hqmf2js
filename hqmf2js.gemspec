# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "hqmf2js"
  s.summary = "A library for converting HQMF files to JavaScript"
  s.description = "A library for converting HQMF files to executable JavaScript suitable for use with the hQuery Gateway"
  s.email = "hquery-talk@googlegroups.com"
  s.homepage = "http://github.com/hquery/hqmf2js"
  s.authors = ["Marc Hadley", "Andre Quina", "Andy Gregorowicz"]
  s.version = '1.3.0'
  
  s.files = s.files = `git ls-files`.split("\n")
  s.add_dependency "rails", "~> 4.2.7"
  s.add_dependency 'health-data-standards', '~>3.7'
  s.add_dependency 'hquery-patient-api', '~> 1.0.4'
end


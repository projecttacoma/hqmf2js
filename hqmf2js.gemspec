# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "hqmf2js"
  s.summary = "A library for converting HQMF files to JavaScript"
  s.description = "A library for converting HQMF files to executable JavaScript suitable for use with the hQuery Gateway"
  s.email = "hquery-talk@googlegroups.com"
  s.homepage = "http://github.com/hquery/hqmf2js"
  s.authors = ["The MITRE Corporation"]
  s.version = '1.4.0'
  s.license = 'Apache-2.0'
  s.files = s.files = `git ls-files`.split("\n")

  s.add_dependency "rails", "~> 4.2"
  s.add_dependency 'health-data-standards', '~> 4.0'
  s.add_dependency 'hquery-patient-api', '~> 1.1'
end

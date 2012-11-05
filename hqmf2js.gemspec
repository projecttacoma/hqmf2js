# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "hqmf2js"
  s.summary = "A library for converting HQMF files to JavaScript"
  s.description = "A library for converting HQMF files to executable JavaScript suitable for use with the hQuery Gateway"
  s.email = "hquery-talk@googlegroups.com"
  s.homepage = "http://github.com/hquery/hqmf2js"
  s.authors = ["Marc Hadley", "Andre Quina", "Andy Gregorowicz"]
  s.version = '1.1.0'
  
  s.add_dependency 'nokogiri', '~> 1.5.2'
  s.add_dependency 'tilt', '~> 1.3.3'
  s.add_dependency 'coffee-script', '~> 2.2.0'
  s.add_dependency 'sprockets', '~> 2.1.2'
  s.add_development_dependency "awesome_print", "~> 0.3"

  s.files = s.files = `git ls-files`.split("\n")
end


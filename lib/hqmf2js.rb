# Top level include file that brings in all the necessary code
require 'bundler/setup'
require 'rubygems'
require 'erb'
require 'ostruct'
require 'singleton'
require 'json'
require 'tilt'
require 'coffee_script'
require 'sprockets'
require 'nokogiri'

require 'hqmf-parser'

require_relative 'hqmf/utilities'
require_relative 'hqmf/types'
require_relative 'hqmf/document'
require_relative 'hqmf/data_criteria'
require_relative 'hqmf/population_criteria'
require_relative 'hqmf/precondition'

require_relative 'json/document'
require_relative 'json/data_criteria'
require_relative 'json/population_criteria'
require_relative 'json/precondition'
require_relative 'json/types'

require_relative 'generator/js'
require_relative 'generator/codes_to_json'
require_relative 'generator/converter'

require_relative 'hqmf_converter/document_converter'
require_relative 'hqmf_converter/data_criteria_converter'
require_relative 'hqmf_converter/population_criteria_converter'
require_relative 'hqmf_converter/precondition_converter'
require_relative 'hqmf_converter/restriction_converter'


Tilt::CoffeeScriptTemplate.default_bare = true

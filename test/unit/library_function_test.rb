require_relative '../test_helper'
require 'hquery-patient-api'

class LibraryFunctionTest < Test::Unit::TestCase
  
  def setup
    @context = get_js_context(HQMF2JS::Generator::JS.library_functions)
  end


  def test_library_function_parses
    @context.eval('hQuery == undefined').must_equal false
    @context.eval('typeof hQuery.Patient').must_equal "function"
    @context.eval('typeof allTrue').must_equal "function"
    @context.eval('typeof atLeastOneTrue').must_equal "function"
    
  end
  
  def test_all_true
    @context.eval('allTrue(false,false,false)').must_equal false
    @context.eval('allTrue(false,true,false)').must_equal false
    @context.eval('allTrue(true,true,true)').must_equal true
  end
  
  def test_at_least_one_true
    @context.eval('atLeastOneTrue(true,false,false)').must_equal true
    @context.eval('atLeastOneTrue(true,true,true)').must_equal true
    @context.eval('atLeastOneTrue(false,false,false)').must_equal false
  end
  
  def test_patient_extensions
    @context.eval('typeof hQuery.Patient.prototype.procedureResults').must_equal "function"
    @context.eval('typeof hQuery.Patient.prototype.laboratoryTests').must_equal "function"
    @context.eval('typeof hQuery.Patient.prototype.allMedications').must_equal "function"
    @context.eval('typeof hQuery.Patient.prototype.allProblems').must_equal "function"
    @context.eval('typeof hQuery.Patient.prototype.allDevices').must_equal "function"
    @context.eval('typeof hQuery.Patient.prototype.activeDiagnoses').must_equal "function"
    @context.eval('typeof hQuery.Patient.prototype.inactiveDiagnoses').must_equal "function"
    @context.eval('typeof hQuery.Patient.prototype.resolvedDiagnoses').must_equal "function"
  end


end
require_relative '../test_helper'

class CodesToJsonTest < Test::Unit::TestCase
  
  def setup
  end


  def test_parsing_from_xml
    
    codes_file_path = File.expand_path("../../fixtures/codes/codes.xml", __FILE__)
    # Parse the code systems that are mapped to the OIDs we support
    codes_json = HQMF2JS::Generator::CodesToJson.hash_to_js(HQMF2JS::Generator::CodesToJson.from_xml(codes_file_path))
    
    @context = get_js_context("var dictionary = #{codes_json}")
    
    @context.eval("dictionary").entries.length.must_equal 18
    @context.eval("dictionary['2.16.840.1.113883.3.464.1.42']").entries.first[0].must_equal "CPT"
    @context.eval("dictionary['2.16.840.1.113883.3.464.1.42']").entries.first[1].length.must_equal 19
    
  end

  def test_parsing_from_xls
    
    codes_file_path = File.expand_path("../../fixtures/codes/codes.xls", __FILE__)
    # Parse the code systems that are mapped to the OIDs we support
    codes_json = HQMF2JS::Generator::CodesToJson.hash_to_js(HQMF2JS::Generator::CodesToJson.from_xls(codes_file_path))

    @context = get_js_context("var dictionary = #{codes_json}")
    @context.eval("dictionary").entries.length.must_equal 12
    @context.eval("dictionary['2.16.840.1.113883.3.464.0001.430']").entries.first[0].must_equal "RxNorm"
    @context.eval("dictionary['2.16.840.1.113883.3.464.0001.430']").entries.first[1].length.must_equal 24
    
  end
  


end
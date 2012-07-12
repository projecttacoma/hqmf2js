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
    @context.eval('allTrue()').must_equal false
  end
  
  def test_at_least_one_true
    @context.eval('atLeastOneTrue(true,false,false)').must_equal true
    @context.eval('atLeastOneTrue(true,true,true)').must_equal true
    @context.eval('atLeastOneTrue(false,false,false)').must_equal false
    @context.eval('atLeastOneTrue()').must_equal false
  end
  
  def test_all_false
    @context.eval('allFalse(false,false,false)').must_equal true
    @context.eval('allFalse(false,true,false)').must_equal false
    @context.eval('allFalse(true,true,true)').must_equal false
    @context.eval('allFalse()').must_equal false
  end
  
  def test_at_least_one_false
    @context.eval('atLeastOneFalse(true,false,false)').must_equal true
    @context.eval('atLeastOneFalse(true,true,true)').must_equal false
    @context.eval('atLeastOneFalse(false,false,false)').must_equal true
    @context.eval('atLeastOneFalse()').must_equal false
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

  def test_code_list
    @context.eval('(new CodeList({"foo": [10,11]})).match(10)').must_equal true
    @context.eval('(new CodeList({"foo": [10,11]})).match({"code": 10})').must_equal true
    @context.eval('(new CodeList({"foo": [10,11]})).match(12)').must_equal false
    @context.eval('(new CodeList({"foo": [10,11]})).match({"code": 12})').must_equal false
  end
  
  def test_pq
    pq = "new PQ(1, 'mo')"
    assert_equal 1, @context.eval("#{pq}.value")
    assert_equal "mo", @context.eval("#{pq}.unit")
    assert @context.eval("#{pq}.lessThan(3)")
    assert @context.eval("#{pq}.greaterThan(0)")
    assert @context.eval("#{pq}.match(1)")
  end
  
  def test_ts
    # TS - Timestamp 2010-01-01
    ts = 'new TS("20110101")'
    ts2 = 'new TS("20100101")'
    ts3 = 'new TS("20120101")'
    assert_equal 2011, @context.eval("#{ts}.asDate().getFullYear()")
    assert_equal 0, @context.eval("#{ts}.asDate().getMonth()")
    assert_equal 1, @context.eval("#{ts}.asDate().getDate()")
    assert_equal 2012, @context.eval("#{ts}.add(new PQ(1, 'a')).asDate().getFullYear()")
    assert_equal 2, @context.eval("#{ts}.add(new PQ(1, 'd')).asDate().getDate()")
    assert_equal 8, @context.eval("#{ts}.add(new PQ(1, 'wk')).asDate().getDate()")
    assert_equal 1, @context.eval("#{ts}.add(new PQ(1, 'h')).asDate().getHours()")
    assert_equal 5, @context.eval("#{ts}.add(new PQ(5, 'min')).asDate().getMinutes()")
    assert_equal 11, @context.eval("#{ts}.add(new PQ(-1, 'mo')).asDate().getMonth()")
    assert @context.eval("#{ts2}.before(#{ts})")
    assert @context.eval("#{ts3}.after(#{ts})")
    assert !@context.eval("#{ts}.before(#{ts2})")
    assert !@context.eval("#{ts}.after(#{ts3})")
    assert @context.eval("#{ts}.beforeOrConcurrent(#{ts})")
    assert @context.eval("#{ts}.afterOrConcurrent(#{ts})")
    ts4 = 'new TS("20000310")'
    ts5 = 'new TS("20110405")'
    ts6 = 'new TS("20000229")'
    ts7 = 'new TS("20110228")'
    ts8 = 'new TS("20120228")'
    assert_equal 11, @context.eval("#{ts4}.difference(#{ts5},'a')")
    assert_equal 11, @context.eval("#{ts5}.difference(#{ts4},'a')")
    assert_equal 10, @context.eval("#{ts6}.difference(#{ts7},'a')")
    assert_equal 10, @context.eval("#{ts7}.difference(#{ts6},'a')")
    assert_equal 1, @context.eval("#{ts7}.difference(#{ts8},'a')")
    assert_equal 1, @context.eval("#{ts8}.difference(#{ts7},'a')")
    ts9 = 'new TS("20000229")'
    ts10 = 'new TS("20010330")'
    ts11 = 'new TS("20101228")'
    ts12 = 'new TS("20110217")'
    ts13 = 'new TS("20080320")'
    ts14 = 'new TS("20080401")'
    assert_equal 13, @context.eval("#{ts9}.difference(#{ts10},'mo')")
    assert_equal 1, @context.eval("#{ts11}.difference(#{ts12},'mo')")
    assert_equal 0, @context.eval("#{ts13}.difference(#{ts14},'mo')")
    ts15 = 'new TS("201203010310")'
    ts16 = 'new TS("201203010520")'
    ts17 = 'new TS("201202292310")'
    ts18 = 'new TS("201203010020")'
    assert_equal 130, @context.eval("#{ts15}.difference(#{ts16},'min')")
    assert_equal 70, @context.eval("#{ts17}.difference(#{ts18},'min')")
    ts19 = 'new TS("201203010310")'
    ts20 = 'new TS("201203010520")'
    ts21 = 'new TS("201202292310")'
    ts22 = 'new TS("201203010010")'
    ts23 = 'new TS("201203010310")'
    ts24 = 'new TS("201203010400")'
    assert_equal 2, @context.eval("#{ts19}.difference(#{ts20},'h')")
    assert_equal 1, @context.eval("#{ts21}.difference(#{ts22},'h')")
    assert_equal 0, @context.eval("#{ts23}.difference(#{ts24},'h')")
    ts25 = 'new TS("200002280900")'
    ts26 = 'new TS("200002292359")'
    ts27 = 'new TS("200012282300")'
    ts28 = 'new TS("200101010800")'
    ts29 = 'new TS("200002280900")'
    ts30 = 'new TS("200002282359")'
    assert_equal 1, @context.eval("#{ts25}.difference(#{ts26},'d')")
    assert_equal 4, @context.eval("#{ts27}.difference(#{ts28},'d')")
    assert_equal 0, @context.eval("#{ts29}.difference(#{ts30},'d')")
    ts31 = 'new TS("20120403")'
    ts32 = 'new TS("20120410")'
    ts33 = 'new TS("20120229")'
    ts34 = 'new TS("20120328")'
    assert_equal 0, @context.eval("#{ts31}.difference(#{ts31},'wk')")
    assert_equal 1, @context.eval("#{ts31}.difference(#{ts32},'wk')")
    assert_equal 4, @context.eval("#{ts33}.difference(#{ts34},'wk')")
  end
  
  def test_cd
    # CD - Code
    cd = "new CD('M')"
    assert_equal 'M', @context.eval("#{cd}.code")
    assert @context.eval("#{cd}.match('M')")
    assert !@context.eval("#{cd}.match('F')")
  end
  
  def test_iv_pq
    # IVL_PQ - Range
    ivl = "new IVL_PQ(new PQ(1, 'mo'), new PQ(10, 'mo'))"
    assert_equal 1, @context.eval("#{ivl}.low_pq.value")
    assert_equal 10, @context.eval("#{ivl}.high_pq.value")
    assert @context.eval("#{ivl}.match(5)")
    assert !@context.eval("#{ivl}.match(0)")
    assert !@context.eval("#{ivl}.match(11)")
    # IVL with null values on the ends
    assert @context.eval("new IVL_PQ(null, new PQ(10, 'mo')).match(5)")
    assert !@context.eval("new IVL_PQ(null, new PQ(10, 'mo')).match(11)")
    assert @context.eval("new IVL_PQ(new PQ(1, 'mo'), null).match(2)")
    assert !@context.eval("new IVL_PQ(new PQ(1, 'mo'), null).match(0)")
  end
  
  def test_ivl_ts
    # IVL_TS - Time Range
    ivl1 = 'new IVL_TS(new TS("20120310"), new TS("20120320"))'
    ivl2 = 'new IVL_TS(new TS("20120312"), new TS("20120320"))'
    assert @context.eval("#{ivl2}.DURING(#{ivl1})")
    assert_equal 2010, @context.eval('getIVL(new Date(2010,1,1)).low.asDate().getFullYear()')
  end
  
  def test_matching_value
    # Matching value
    assert @context.eval("matchingValue(5, new IVL_PQ(PQ(3, 'mo'), new PQ(9, 'mo')))")
    assert !@context.eval("matchingValue(12, new IVL_PQ(PQ(3, 'mo'), new PQ(9, 'mo')))")
  end
  
  def test_count
    # COUNT
    events0 = '[]'
    events1 = '[1]'
    events2 = '[1,2]'
    exactly0 = 'new IVL_PQ(new PQ(0), new PQ(0))'
    exactly1 = 'new IVL_PQ(new PQ(1), new PQ(1))'
    moreThanZero = 'new IVL_PQ(new PQ(1))'
    lessThanTwo = 'new IVL_PQ(null, new PQ(1))'
    assert @context.eval("COUNT(#{events0}, #{exactly0})")
    assert !@context.eval("COUNT(#{events0}, #{exactly1})")
    assert !@context.eval("COUNT(#{events0}, #{moreThanZero})")
    assert @context.eval("COUNT(#{events0}, #{lessThanTwo})")
    assert !@context.eval("COUNT(#{events1}, #{exactly0})")
    assert @context.eval("COUNT(#{events1}, #{exactly1})")
    assert @context.eval("COUNT(#{events1}, #{moreThanZero})")
    assert @context.eval("COUNT(#{events1}, #{lessThanTwo})")
    assert !@context.eval("COUNT(#{events2}, #{exactly0})")
    assert !@context.eval("COUNT(#{events2}, #{exactly1})")
    assert @context.eval("COUNT(#{events2}, #{moreThanZero})")
    assert !@context.eval("COUNT(#{events2}, #{lessThanTwo})")
  end
  
  def test_union
    # UNION
    events0 = '[]'
    events1 = '[1]'
    events2 = '[2,3]'
    assert @context.eval("UNION().length===0")
    assert @context.eval("UNION(#{events0}).length===0")
    assert @context.eval("UNION(#{events1}).length===1")
    assert @context.eval("UNION(#{events1},#{events2}).length===3")
    assert @context.eval("UNION(#{events0},#{events2}).length===2")
  end

  def test_xproduct  
    # XPRODUCT
    events0 = '[]'
    events1 = '[1]'
    events2 = '[2,3]'
    assert @context.eval("XPRODUCT().length===0")
    assert @context.eval("XPRODUCT(#{events0}).length===0")
    assert !@context.eval("XPRODUCT(#{events0}).iterator().hasNext()")
    assert @context.eval("XPRODUCT(#{events1}).length===1")
    assert @context.eval("XPRODUCT(#{events1}).iterator().hasNext()")
    assert @context.eval("XPRODUCT(#{events1}).iterator().next().length===1")
    assert @context.eval("XPRODUCT(#{events1}).iterator().next()[0]===1")
    assert @context.eval("XPRODUCT(#{events1},#{events2}).length===3")
    assert @context.eval("XPRODUCT(#{events0},#{events2}).length===2")
    assert @context.eval("XPRODUCT(#{events0},#{events2}).iterator().hasNext()")
    assert @context.eval("XPRODUCT(#{events0},#{events2}).iterator().next().length===1")
    assert @context.eval("XPRODUCT(#{events0},#{events2}).iterator().next()[0]===2")
    @context.eval("var iterator = XPRODUCT(#{events1},#{events2}).iterator()")
    assert @context.eval("iterator.hasNext()")
    @context.eval('var combo1 = iterator.next()')
    assert @context.eval('combo1.length===2')
    assert @context.eval("combo1[0]===1")
    assert @context.eval("combo1[1]===2")
    assert @context.eval("iterator.hasNext()")
    @context.eval('var combo2 = iterator.next()')
    assert @context.eval('combo2.length===2')
    assert @context.eval("combo2[0]===1")
    assert @context.eval("combo2[1]===3")
    assert !@context.eval("iterator.hasNext()")
    if RUBY_PLATFORM!='java'
      assert_raise V8::JSError, "No more entries" do
        @context.eval('var combo3 = iterator.next()')
      end
    end
  end
  
  def test_temporal_operators
    # Events and bounds for temporal operators
    @context.eval('var events1 = [{"asIVL_TS": function() {return new IVL_TS(new TS("20120105"), new TS("20120105"));}}]')
    @context.eval('var events2 = [{"asIVL_TS": function() {return new IVL_TS(new TS("20120102"), new TS("20120105"));}}]')
    @context.eval('var bound1 = [{"asIVL_TS": function() {return new IVL_TS(new TS("20120105"), new TS("20120105"));}}]')
    @context.eval('var bound2 = [{"asIVL_TS": function() {return new IVL_TS(new TS("20120107"), new TS("20120107"));}}]')
    @context.eval('var bound3 = [{"asIVL_TS": function() {return new IVL_TS(new TS("20120103"), new TS("20120107"));}}]')
    @context.eval('var bound4 = [{"asIVL_TS": function() {return new IVL_TS(new TS("20120106"), new TS("20120107"));}}]')
    @context.eval('var bound5 = {"asIVL_TS": function() {return new IVL_TS(new TS("20120106"), new TS("20120107"));}}')
    @context.eval('var range1 = new IVL_PQ(null, new PQ(1, "d"))')
    @context.eval('var range2 = new IVL_PQ(new PQ(1, "d"), null)')
    
    # DURING
    assert_equal 1, @context.eval('DURING(events1, bound1)').count
    assert_equal 0, @context.eval('DURING(events1, bound2)').count
    assert_equal 1, @context.eval('DURING(events1, bound3)').count
    assert_equal 0, @context.eval('DURING(events1, bound4)').count
    assert_equal 0, @context.eval('DURING(events1, bound5)').count
    assert_equal 1, @context.eval('DURING(events2, bound3)').count
    assert_equal 0, @context.eval('DURING(events2, bound4)').count
    assert_equal 0, @context.eval('DURING(events2, bound5)').count
    assert_equal 1, @context.eval('DURING(events2, bound1)').count
    assert_equal 0, @context.eval('DURING(events2, bound2)').count
    assert_equal 1, @context.eval('DURING(events1, XPRODUCT(bound1))').count
    assert_equal 0, @context.eval('DURING(events1, XPRODUCT(bound2))').count
    assert_equal 0, @context.eval('DURING(events1, XPRODUCT(bound1, bound2))').count
    assert_equal 1, @context.eval('DURING(events1, XPRODUCT(bound3))').count
    assert_equal 1, @context.eval('DURING(events1, XPRODUCT(bound1, bound3))').count
    assert_equal 0, @context.eval('DURING(events1, XPRODUCT(bound4))').count
    assert_equal 0, @context.eval('DURING(events1, XPRODUCT(bound5))').count
    assert_equal 1, @context.eval('DURING(events2, XPRODUCT(bound3))').count
    assert_equal 0, @context.eval('DURING(events2, XPRODUCT(bound4))').count
    assert_equal 0, @context.eval('DURING(events2, XPRODUCT(bound5))').count
    assert_equal 1, @context.eval('DURING(events2, XPRODUCT(bound1))').count
    assert_equal 0, @context.eval('DURING(events2, XPRODUCT(bound2))').count
    
    # SBS
    assert_equal 0, @context.eval('SBS(events1, bound1)').count
    assert_equal 0, @context.eval('SBS(events2, bound1, range1)').count
    assert_equal 1, @context.eval('SBS(events2, bound1)').count
    assert_equal 1, @context.eval('SBS(events2, bound1, range2)').count
    
    # SAS
    assert_equal 0, @context.eval('SAS(events1, bound1)').count
    assert_equal 0, @context.eval('SAS(events2, bound1, range1)').count
    assert_equal 0, @context.eval('SAS(events2, bound1)').count
    assert_equal 0, @context.eval('SAS(events2, bound1, range2)').count
    
    # SBE
    assert_equal 0, @context.eval('SBE(events1, bound1)').count
    assert_equal 1, @context.eval('SBE(events1, bound2)').count
    
    # SAE
    assert_equal 0, @context.eval('SAE(events1, bound1)').count
    assert_equal 1, @context.eval('SAE(bound2, events1)').count
    
    # EBS
    assert_equal 0, @context.eval('EBS(events1, bound1)').count
    assert_equal 1, @context.eval('EBS(events1, bound2)').count
    
    # EAS
    assert_equal 0, @context.eval('EAS(events1, bound1)').count
    assert_equal 1, @context.eval('EAS(events1, bound3)').count
    
    # EBE
    assert_equal 0, @context.eval('EBE(events1, bound1)').count
    assert_equal 1, @context.eval('EBE(events1, bound2)').count
    
    # EAE
    assert_equal 0, @context.eval('EAE(events1, bound1)').count
    assert_equal 1, @context.eval('EAE(bound3, events2)').count
    
    # SDU
    assert_equal 1, @context.eval('SDU(events1, bound1)').count
    assert_equal 0, @context.eval('SDU(events1, bound2)').count
    
    # EDU
    assert_equal 1, @context.eval('EDU(events1, bound1)').count
    assert_equal 0, @context.eval('EDU(events1, bound2)').count
    
    # ECW
    assert_equal 1, @context.eval('ECW(events1, bound1)').count
    assert_equal 0, @context.eval('ECW(events1, bound2)').count
    
    # SCW
    assert_equal 1, @context.eval('ECW(events1, bound1)').count
    assert_equal 0, @context.eval('ECW(events1, bound2)').count
    
    # CONCURRENT
    assert_equal 1, @context.eval('CONCURRENT(events1, bound1)').count
    assert_equal 0, @context.eval('CONCURRENT(events1, bound2)').count
  end
  
  def test_ordinal_operators
    # Ordinal operators
    ts20100101 = '{"timeStamp": function() {return new Date(2010,0,1);}}'
    ts20100201 = '{"timeStamp": function() {return new Date(2010,1,1);}}'
    ts20100301 = '{"timeStamp": function() {return new Date(2010,2,1);}}'
    ts20100401 = '{"timeStamp": function() {return new Date(2010,3,1);}}'
    ts20100501 = '{"timeStamp": function() {return new Date(2010,4,1);}}'
    events0 = "[]"
    events1 = "[#{ts20100101}]"
    events2 = "[#{ts20100101},#{ts20100201}]"
    events3 = "[#{ts20100101},#{ts20100201},#{ts20100301}]"
    events4 = "[#{ts20100101},#{ts20100201},#{ts20100301},#{ts20100401}]"
    events5 = "[#{ts20100101},#{ts20100201},#{ts20100301},#{ts20100401},#{ts20100501}]"
    events6 = "[#{ts20100501},#{ts20100401},#{ts20100301},#{ts20100201},#{ts20100101}]"
    
    assert_equal 0, @context.eval("RECENT(#{events0})").count
    assert_equal 0, @context.eval("LAST(#{events0})").count
    assert_equal 0, @context.eval("FIRST(#{events0})").count
    assert_equal 0, @context.eval("SECOND(#{events1})").count
    assert_equal 0, @context.eval("THIRD(#{events2})").count
    assert_equal 0, @context.eval("FOURTH(#{events3})").count
    assert_equal 0, @context.eval("FIFTH(#{events4})").count

    assert_equal 1, @context.eval("RECENT(#{events1})").count
    assert_equal 1, @context.eval("LAST(#{events1})").count
    assert_equal 1, @context.eval("FIRST(#{events1})").count
    assert_equal 1, @context.eval("SECOND(#{events2})").count
    assert_equal 1, @context.eval("THIRD(#{events3})").count
    assert_equal 1, @context.eval("FOURTH(#{events4})").count
    assert_equal 1, @context.eval("FIFTH(#{events5})").count

    assert_equal 1, @context.eval("LAST(#{events6})").count
    assert_equal 4, @context.eval("LAST(#{events6})[0].timeStamp().getMonth()")
    assert_equal 1, @context.eval("RECENT(#{events6})").count
    assert_equal 4, @context.eval("RECENT(#{events6})[0].timeStamp().getMonth()")
    assert_equal 1, @context.eval("FIRST(#{events6})").count
    assert_equal 0, @context.eval("FIRST(#{events6})[0].timeStamp().getMonth()")
    assert_equal 1, @context.eval("SECOND(#{events6})").count
    assert_equal 1, @context.eval("SECOND(#{events6})[0].timeStamp().getMonth()")
    assert_equal 1, @context.eval("THIRD(#{events6})").count
    assert_equal 2, @context.eval("THIRD(#{events6})[0].timeStamp().getMonth()")
    assert_equal 1, @context.eval("FOURTH(#{events6})").count
    assert_equal 3, @context.eval("FOURTH(#{events6})[0].timeStamp().getMonth()")
    assert_equal 1, @context.eval("FIFTH(#{events6})").count
    assert_equal 4, @context.eval("FIFTH(#{events6})[0].timeStamp().getMonth()")
  end
  
  def test_summary_operators  
    # MIN and MAX
    v10 = '{"value": function() {return {"scalar": 10};}}'
    v20 = '{"value": function() {return {"scalar": 20};}}'
    events0 = "[]"
    events2 = "[#{v10},#{v20}]"
    exactly10 = 'new IVL_PQ(new PQ(10), new PQ(10))'
    exactly20 = 'new IVL_PQ(new PQ(20), new PQ(20))'
    moreThan10 = 'new IVL_PQ(new PQ(11))'
    lessThan20 = 'new IVL_PQ(null, new PQ(19))'
    between15and25 = 'new IVL_PQ(new PQ(15), new PQ(25))'
    assert !@context.eval("MIN(#{events0},#{exactly10})")
    assert !@context.eval("MAX(#{events0},#{exactly10})")
    assert !@context.eval("MIN(#{events0},#{exactly20})")
    assert !@context.eval("MAX(#{events0},#{exactly20})")
    assert @context.eval("MIN(#{events2},#{exactly10})")
    assert !@context.eval("MAX(#{events2},#{exactly10})")
    assert !@context.eval("MIN(#{events2},#{exactly20})")
    assert @context.eval("MAX(#{events2},#{exactly20})")
    assert !@context.eval("MIN(#{events2},#{moreThan10})")
    assert @context.eval("MAX(#{events2},#{moreThan10})")
    assert @context.eval("MIN(#{events2},#{lessThan20})")
    assert !@context.eval("MAX(#{events2},#{lessThan20})")
    assert !@context.eval("MIN(#{events2},#{between15and25})")
    assert @context.eval("MAX(#{events2},#{between15and25})")
  end
end
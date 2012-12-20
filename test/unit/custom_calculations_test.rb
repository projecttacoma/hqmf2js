require_relative '../test_helper'
require 'hquery-patient-api'

class CustomCalculationsTest < Test::Unit::TestCase
  
  def setup
    @context = get_js_context(HQMF2JS::Generator::JS.library_functions)
    test_initialize_js = 
    "
      inr1 = new hQuery.CodedEntry({time:#{Time.gm(2010,1,5).to_i}, values:[{scalar:'2.8'}]})
      inr2 = new hQuery.CodedEntry({time:#{Time.gm(2010,1,18).to_i}, values:[{scalar:'3.5'}]})
      inr3 = new hQuery.CodedEntry({time:#{Time.gm(2010,2,2).to_i}, values:[{scalar:'3.4'}]})
      inr4 = new hQuery.CodedEntry({time:#{Time.gm(2010,2,15).to_i}, values:[{scalar:'3.9'}]})
      inr5 = new hQuery.CodedEntry({time:#{Time.gm(2010,3,10).to_i}, values:[{scalar:'1.7'}]})
      inr6 = new hQuery.CodedEntry({time:#{Time.gm(2010,3,24).to_i}, values:[{scalar:'2.3'}]})
      inr7 = new hQuery.CodedEntry({time:#{Time.gm(2010,4,12).to_i}, values:[{scalar:'2.4'}]})
      inr8 = new hQuery.CodedEntry({time:#{Time.gm(2010,5,13).to_i}, values:[{scalar:'3.2'}]})
      inr9 = new hQuery.CodedEntry({time:#{Time.gm(2010,5,27).to_i}, values:[{scalar:'3.5'}]})
      inr10 = new hQuery.CodedEntry({time:#{Time.gm(2010,6,10).to_i}, values:[{scalar:'3.5'}]})
      inr11 = new hQuery.CodedEntry({time:#{Time.gm(2010,6,24).to_i}, values:[{scalar:'3.4'}]})
      inr12 = new hQuery.CodedEntry({time:#{Time.gm(2010,7,8).to_i}, values:[{scalar:'2.1'}]})
      inr13 = new hQuery.CodedEntry({time:#{Time.gm(2010,7,22).to_i}, values:[{scalar:'2.6'}]})
      
      list = new hqmf.CustomCalc.PercentTTREntries([inr1,inr2,inr3,inr4,inr5,inr6,inr7,inr8,inr9,inr10,inr11,inr12,inr13])
      
      inr_b1 = new hQuery.CodedEntry({time:#{Time.gm(2010,4,1).to_i}, values:[{scalar:'2.2'}]})
      inr_b2 = new hQuery.CodedEntry({time:#{Time.gm(2010,5,7).to_i}, values:[{scalar:'2.0'}]})
      inr_b3 = new hQuery.CodedEntry({time:#{Time.gm(2010,6,4).to_i}, values:[{scalar:'2.7'}]})
      inr_b4 = new hQuery.CodedEntry({time:#{Time.gm(2010,7,10).to_i}, values:[{scalar:'2.2'}]})
      inr_b5 = new hQuery.CodedEntry({time:#{Time.gm(2010,8,12).to_i}, values:[{scalar:'2.3'}]})
      inr_b6 = new hQuery.CodedEntry({time:#{Time.gm(2010,9,11).to_i}, values:[{scalar:'2.8'}]})
      inr_b7 = new hQuery.CodedEntry({time:#{Time.gm(2010,10,9).to_i}, values:[{scalar:'2.8'}]})
      inr_b8 = new hQuery.CodedEntry({time:#{Time.gm(2010,10,17).to_i}, values:[{scalar:'2.1'}]})
      inr_b9 = new hQuery.CodedEntry({time:#{Time.gm(2010,10,31).to_i}, values:[{scalar:'1.8'}]})
      
      list2 = new hqmf.CustomCalc.PercentTTREntries([inr_b1,inr_b2,inr_b3,inr_b4,inr_b5,inr_b6,inr_b7,inr_b8,inr_b9])
    "
    @context.eval(test_initialize_js)
    
    
  end


  def test_inr_results
    @context.eval("typeof(hqmf.CustomCalc.PercentTTREntries) === 'function'").must_equal true
    assert @context.eval("Math.abs(list.calculateDaysInRange(inr1,inr2) - 3.714285714285717) < .001")
    assert @context.eval("Math.abs(list.calculateDaysInRange(inr2,inr3)) == 0 ")
    assert @context.eval("Math.abs(list.calculateDaysInRange(inr3,inr4))  == 0")
    assert @context.eval("Math.abs(list.calculateDaysInRange(inr4,inr5) - 10.45454545) < .001")
    assert @context.eval("Math.abs(list.calculateDaysInRange(inr5,inr6) - 7) < .001")
    assert @context.eval("Math.abs(list.calculateDaysInRange(inr6,inr7) - 19) < .001")
    assert @context.eval("Math.abs(list.calculateDaysInRange(inr7,inr8) - 23.25) < .001")
    assert @context.eval("Math.abs(list.calculateDaysInRange(inr8,inr9)) == 0")
    assert @context.eval("Math.abs(list.calculateDaysInRange(inr9,inr10)) == 0")
    assert @context.eval("Math.abs(list.calculateDaysInRange(inr10,inr11)) == 0")
    assert @context.eval("Math.abs(list.calculateDaysInRange(inr11,inr12) - 9.692307692) < .001")
    assert @context.eval("Math.abs(list.calculateDaysInRange(inr12,inr13) - 14) < .001")
    
  end
  
  def test_total_number_of_days
    @context.eval("list.totalNumberOfDays()").must_equal 198
  end

  def test_calculate_ttr
    assert @context.eval("Math.abs(list.calculateTTR() - 87.11113886) < .001")
  end

  def test_calculate_percent_ttr
    assert @context.eval("Math.abs(list.calculatePercentTTR() - 43.99552468) < .001")
  end
  
  
end

require_relative '../test_helper'
require 'hquery-patient-api'

class SpecificsTest < Test::Unit::TestCase
  
  def setup
    @context = get_js_context(HQMF2JS::Generator::JS.library_functions)
    test_initialize_js = 
    "
      Specifics.initialize('OccurrenceAEncounter','OccurrenceBEncounter')
    "
    @context.eval(test_initialize_js)
  end


  def test_specifics_initialized_proper
    
    @context.eval('Specifics.KEY_LOOKUP[0]').must_equal 'OccurrenceAEncounter'
    @context.eval('Specifics.KEY_LOOKUP[1]').must_equal 'OccurrenceBEncounter'
    
  end
  
  def test_specifics_row_union
    
    union_rows = "
      var row1 = new Row({'OccurrenceAEncounter':{'id':1}});
      var specific1 = new Specifics([row1]);
      var row2 = new Row({'OccurrenceBEncounter':{'id':2}});
      var specific2 = new Specifics([row2]);
      result = specific1.union(specific2);
      result.rows.length;
    "
    
    @context.eval(union_rows).must_equal 2
    @context.eval("result.rows[0].values[0].id").must_equal 1
    @context.eval("result.rows[0].values[1]").must_equal '*'
    @context.eval("result.rows[1].values[0]").must_equal '*'
    @context.eval("result.rows[1].values[1].id").must_equal 2
    
  end

  def test_row_creation
    
    rows = "
      var row1 = new Row({'OccurrenceAEncounter':{'id':1}});
      var row2 = new Row({'OccurrenceBEncounter':{'id':2}});
      var row3 = new Row({'OccurrenceAEncounter':{'id':1},'OccurrenceBEncounter':{'id':2}});
      var row4 = new Row({});
    "
    
    @context.eval(rows)
    @context.eval("row1.values[0].id").must_equal 1
    @context.eval("row1.values[1]").must_equal '*'
    @context.eval("row2.values[0]").must_equal '*'
    @context.eval("row2.values[1].id").must_equal 2
    @context.eval("row3.values[0].id").must_equal 1
    @context.eval("row3.values[1].id").must_equal 2
    @context.eval("row4.values[0]").must_equal '*'
    @context.eval("row4.values[1]").must_equal '*'
  end
    

  def test_row_match
    rows = "
      var row1 = new Row({});
    "
    @context.eval(rows)
    @context.eval("Row.match('*', {'id':1}).id").must_equal 1
    @context.eval("Row.match({'id':2}, '*').id").must_equal 2
    @context.eval("Row.match({'id':1}, {'id':1}).id").must_equal 1
    @context.eval("Row.match('*', '*')").must_equal '*'
    @context.eval("typeof(Row.match({'id':3}, {'id':2})) === 'undefined'").must_equal true
    
  end
  
  def test_row_intersect
    
    rows = "
      var row1 = new Row({'OccurrenceAEncounter':{'id':1}});
      var row2 = new Row({'OccurrenceBEncounter':{'id':2}});
      var row3 = new Row({'OccurrenceAEncounter':{'id':1},'OccurrenceBEncounter':{'id':2}});
      var row4 = new Row({'OccurrenceAEncounter':{'id':2},'OccurrenceBEncounter':{'id':2}});
      var row5 = new Row({'OccurrenceAEncounter':{'id':3},'OccurrenceBEncounter':{'id':3}});
      var row6 = new Row({});
    "
    
    @context.eval(rows)
    @context.eval("row1.intersect(row2).values[0].id").must_equal 1
    @context.eval("row1.intersect(row2).values[1].id").must_equal 2
    @context.eval("row2.intersect(row1).values[0].id").must_equal 1
    @context.eval("row2.intersect(row1).values[1].id").must_equal 2
    @context.eval("row1.intersect(row3).values[0].id").must_equal 1
    @context.eval("row1.intersect(row3).values[1].id").must_equal 2
    @context.eval("row2.intersect(row3).values[0].id").must_equal 1
    @context.eval("row2.intersect(row3).values[1].id").must_equal 2
    @context.eval("typeof(row1.intersect(row4)) === 'undefined'").must_equal true
    @context.eval("row2.intersect(row4).values[0].id").must_equal 2
    @context.eval("row2.intersect(row4).values[1].id").must_equal 2
    @context.eval("typeof(row1.intersect(row5)) === 'undefined'").must_equal true
    @context.eval("typeof(row2.intersect(row5)) === 'undefined'").must_equal true
    @context.eval("typeof(row3.intersect(row4)) === 'undefined'").must_equal true
    @context.eval("row1.intersect(row6).values[0].id").must_equal 1
    @context.eval("row1.intersect(row6).values[1]").must_equal '*'
    @context.eval("row2.intersect(row6).values[0]").must_equal '*'
    @context.eval("row2.intersect(row6).values[1].id").must_equal 2
    @context.eval("row6.intersect(row6).values[0]").must_equal '*'
    @context.eval("row6.intersect(row6).values[1]").must_equal '*'
    
  end
  
  def test_specifics_row_intersection
    
    intersect_rows = "
      var row1 = new Row({'OccurrenceAEncounter':{'id':1}});
      var row2 = new Row({'OccurrenceBEncounter':{'id':2}});
      var row3 = new Row({'OccurrenceAEncounter':{'id':1},'OccurrenceBEncounter':{'id':2}});
      var row4 = new Row({'OccurrenceAEncounter':{'id':2},'OccurrenceBEncounter':{'id':2}});
      var row5 = new Row({'OccurrenceAEncounter':{'id':3},'OccurrenceBEncounter':{'id':3}});
      var row6 = new Row({'OccurrenceAEncounter':{'id':1},'OccurrenceBEncounter':{'id':3}});
      
      var specific1 = new Specifics([row1]);
      var specific2 = new Specifics([row2]);
      var specific3 = new Specifics([row3,row4]);
      var specific4 = new Specifics([row3,row6]);
      var specific5 = new Specifics([row5,row6]);
    "
    
    @context.eval(intersect_rows)
    @context.eval("specific1.intersect(specific2).rows.length").must_equal 1
    @context.eval("specific1.intersect(specific2).rows[0].values[0].id").must_equal 1
    @context.eval("specific1.intersect(specific2).rows[0].values[1].id").must_equal 2

    @context.eval("specific1.intersect(specific3).rows.length").must_equal 1
    @context.eval("specific1.intersect(specific3).rows[0].values[0].id").must_equal 1
    @context.eval("specific1.intersect(specific3).rows[0].values[1].id").must_equal 2

    @context.eval("specific1.intersect(specific4).rows.length").must_equal 2
    @context.eval("specific1.intersect(specific4).rows[0].values[0].id").must_equal 1
    @context.eval("specific1.intersect(specific4).rows[0].values[1].id").must_equal 2
    @context.eval("specific1.intersect(specific4).rows[1].values[0].id").must_equal 1
    @context.eval("specific1.intersect(specific4).rows[1].values[1].id").must_equal 3

    @context.eval("specific2.intersect(specific3).rows.length").must_equal 2
    @context.eval("specific2.intersect(specific3).rows[0].values[0].id").must_equal 1
    @context.eval("specific2.intersect(specific3).rows[0].values[1].id").must_equal 2
    @context.eval("specific2.intersect(specific3).rows[1].values[0].id").must_equal 2
    @context.eval("specific2.intersect(specific3).rows[1].values[1].id").must_equal 2
    
    @context.eval("specific2.intersect(specific5).rows.length").must_equal 0
    
    @context.eval("specific4.intersect(specific5).rows.length").must_equal 1
    @context.eval("specific4.intersect(specific5).rows[0].values[0].id").must_equal 1
    @context.eval("specific4.intersect(specific5).rows[0].values[1].id").must_equal 3
    
  end
  
  
end

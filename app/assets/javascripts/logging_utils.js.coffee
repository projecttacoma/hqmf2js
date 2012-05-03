class @Logger
  @logger: []
  @info: (string) ->
    @logger.push(string)
  @enabled: true
  @initialized: false
  @stringify: (object) ->
    if !_.isUndefined(object.length)
      "#{object.length} entries" 
    else
      "#{object}"
  @asBoolean: (object) ->
    if !_.isUndefined(object.length)
      object.length>0 
    else
      object
  @classNameFor: (object) ->
    funcNameRegex = ///function (.+)\(///;
    results = funcNameRegex.exec(object.constructor.toString());
    if (results and results.length > 1)
      results[1]
    else
      ""
  @codedValuesAsString: (codedValues) ->
    "["+_.reduce(codedValues, (memo, entry) -> 
      memo.push("#{entry.codeSystemName()}:#{entry.code()}");
      memo
    , []).join(',')+"]"
    

@enableMeasureLogging = (hqmfjs) ->
  _.each(_.functions(hqmfjs), (method) ->
    hqmfjs[method] = _.wrap(hqmfjs[method], (func, patient) ->
      Logger.info(method+":")
      result = func(patient)
      Logger.info("#{method} -> #{Logger.asBoolean(result)}")
      return result;
    );
  );

@enableLogging =->
  if (!Logger.initialized)
    Logger.initialized=true
    
    _.each(_.functions(hQuery.Patient.prototype), (method) ->
      if (hQuery.Patient.prototype[method].length == 0)
        hQuery.Patient.prototype[method] = _.wrap(hQuery.Patient.prototype[method], (func) ->
          Logger.info("called patient.#{method}():")
          func = _.bind(func, this)
          result = func()
          Logger.info("patient.#{method}() -> #{Logger.stringify(result)}")
          return result;);
      else
        hQuery.Patient.prototype[method] = _.wrap(hQuery.Patient.prototype[method], (func) ->
          args = Array.prototype.slice.call(arguments,1)
          Logger.info("called patient.#{method}(#{args}):")
          result = func.apply(this, args)
          Logger.info("patient.#{method}(#{args}) -> #{Logger.stringify(result)}")
          return result;);
        
    );
    
    hQuery.CodedEntryList.prototype.match = _.wrap(hQuery.CodedEntryList.prototype.match, (func, codeSet, start, end) ->
      
      if (codeSet)
        Logger.info("matching: codeSets(#{_.keys(codeSet).join(",")}), #{start}, #{end}")
      else
        Logger.info("matching: WARNING: CODE SETS ARE NULL, #{start}, #{end}")
        
      func = _.bind(func, this, codeSet,start,end)
      result = func(codeSet,start,end)
      Logger.info("matched -> #{Logger.stringify(result)}")
      return result;
    );
    
    hQuery.CodedEntry.prototype.includesCodeFrom = _.wrap(hQuery.CodedEntry.prototype.includesCodeFrom, (func, codeSet) ->
      func = _.bind(func, this, codeSet)
      result = func(codeSet)
      matchText = "--- noMatch"
      matchText = "+++ validMatch" if result
      
      Logger.info("#{matchText}: -> #{Logger.classNameFor(this)}:#{this.freeTextType()}:#{this.date()}:#{Logger.codedValuesAsString(this.type())}")
      
      return result;
    );
    
    @getCodes = _.wrap(@getCodes, (func, oid) -> 
      codes = func(oid)
      Logger.info("accessed codes: #{oid}")
      codes
      )
  
    @atLeastOneTrue = _.wrap(@atLeastOneTrue, (func) -> 
      args = Array.prototype.slice.call(arguments,1)
      Logger.info("called atLeastOneTrue(#{args}):")
      result = func.apply(this, args)
      Logger.info("atLeastOneTrue -> #{result}")
      result
    )
               
    @allTrue = _.wrap(@allTrue, (func) -> 
      args = Array.prototype.slice.call(arguments,1)
      Logger.info("called allTrue(#{args}):")
      result = func.apply(this, args)
      Logger.info("allTrue -> #{result}")
      result
    )

class @Logger
  @logger: []
  @info: (string) ->
    @logger.push("#{Logger.indent()}#{string}")
  @enabled: true
  @initialized: false
  @indentCount = 0
  @indent: ->
    indent = ''
    (indent+=' ' for num in [0..@indentCount*8])
    indent
  @stringify: (object) ->
    if object and !_.isUndefined(object) and !_.isUndefined(object.length)
      "#{object.length} entries" 
    else
      "#{object}"
  @asBoolean: (object) ->
    if object and !_.isUndefined(object) and !_.isUndefined(object.length)
      object.length>0 
    else
      object
  @toJson: (value) ->
    if (typeof(tojson) == 'function')
      tojson(value)
    else
      JSON.stringify(value)
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
      Logger.info("#{method}:")
      Logger.indentCount++
      result = func(patient)
      Logger.indentCount--
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
      
      # if (codeSet)
      #   Logger.info("matching: codeSets(#{_.keys(codeSet).join(",")}), #{start}, #{end}")
      # else
      #   Logger.info("matching: WARNING: CODE SETS ARE NULL, #{start}, #{end}")
        
      func = _.bind(func, this, codeSet,start,end)
      result = func(codeSet,start,end)
      Logger.info("matched -> #{Logger.stringify(result)}")
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
      Logger.indentCount++
      result = func.apply(this, args)
      Logger.indentCount--
      Logger.info("atLeastOneTrue -> #{result}")
      result
    )
    
    @allTrue = _.wrap(@allTrue, (func) -> 
      args = Array.prototype.slice.call(arguments,1)
      Logger.info("called allTrue(#{args}):")
      Logger.indentCount++
      result = func.apply(this, args)
      Logger.indentCount--
      Logger.info("allTrue -> #{result}")
      result
    )

    @allFalse = _.wrap(@allFalse, (func) -> 
      args = Array.prototype.slice.call(arguments,1)
      Logger.info("called allFalse(#{args}):")
      Logger.indentCount++
      result = func.apply(this, args)
      Logger.indentCount--
      Logger.info("allFalse -> #{result}")
      result
    )

    @atLeastOneFalse = _.wrap(@atLeastOneFalse, (func) -> 
      args = Array.prototype.slice.call(arguments,1)
      Logger.info("called atLeastOneFalse(#{args}):")
      Logger.indentCount++
      result = func.apply(this, args)
      Logger.indentCount--
      Logger.info("atLeastOneFalse -> #{result}")
      result
    )
    
    @eventsMatchBounds = _.wrap(@eventsMatchBounds, (func, events, bounds, methodName, range) -> 
      args = Array.prototype.slice.call(arguments,1)
      result = func(events, bounds, methodName, range)
      Logger.info("#{methodName}(Events: #{Logger.stringify(events)}, Bounds: #{Logger.stringify(bounds)}, Range: #{Logger.toJson(range)}) -> #{Logger.stringify(result)}")
      result
    )

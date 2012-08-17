
wrap = (func, wrapper) ->
  () ->
    args = [func].concat(Array::slice.call(arguments, 0));
    wrapper.apply(this, args);

bind = (func, context) ->
  
  return Function::bind.apply(func, Array::slice.call(arguments, 1)) if (func.bind == Function::bind && Function::bind)
  throw new TypeError if (!_.isFunction(func)) 
  args = Array::slice.call(arguments, 2)
  return bound = ->
    ctor = ->
    return func.apply(context, args.concat(Array::slice.call(arguments))) if (!(this instanceof bound)) 
    ctor.prototype = func.prototype
    self = new ctor
    result = func.apply(self, args.concat(Array::slice.call(arguments)))
    return result if (Object(result) == result) 
    self

Array::unique = ->
  output = {}
  output[@[key]] = @[key] for key in [0...@length]
  value for key, value of output

Array::reduce = (accumulator) ->
  throw new TypeError("Object is null or undefined") if (this==null or this==undefined) 
  i = 0
  l = this.length >> 0
  curr=undefined
  
  throw new TypeError("First argument is not callable") if(typeof accumulator != "function")
  
  if(arguments.length < 2) 
    throw new TypeError("Array length is 0 and no second argument") if (l == 0) 
    curr = this[0]
    i = 1
  else
    curr = arguments[1]

  while (i < l) 
    curr = accumulator.call(undefined, curr, this[i], i, this) if(`i in this`) 
    ++i
    
  
  return curr

###
  {
    rows: [
      [1,3,5],
      [1,7,8],
    ]
  }
###
class Specifics
  
  @OCCURRENCES
  @KEY_LOOKUP
  @TYPE_LOOKUP
  @INITIALIZED: false
  @PATIENT: null
  @ANY = '*'
  
  @initialize: (patient, hqmfjs, occurrences...)->
    Specifics.OCCURRENCES = occurrences
    Specifics.KEY_LOOKUP = {}
    Specifics.TYPE_LOOKUP = {}
    Specifics.FUNCTION_LOOKUP = {}
    Specifics.PATIENT = patient
    Specifics.HQMFJS = hqmfjs
    for occurrenceKey,i in occurrences
      Specifics.KEY_LOOKUP[i] = occurrenceKey.id
      Specifics.FUNCTION_LOOKUP[i] = occurrenceKey.function
      Specifics.TYPE_LOOKUP[occurrenceKey.type] ||= []
      Specifics.TYPE_LOOKUP[occurrenceKey.type].push(i)
  
  constructor: (rows=[])->
    @rows = rows
  
  addRows: (rows) ->
    @rows = @rows.concat(rows)
  
  union: (other) ->
    value = new Specifics()
    value.rows = @rows.concat(other.rows)
    value
  
  intersect: (other) ->
    value = new Specifics()
    for leftRow in @rows
      for rightRow in other.rows
        result = leftRow.intersect(rightRow)
        value.rows.push(result) if result?
    value
  
  negate: ->
    negatedRows = []
    keys = []
    allValues = []
    for index in @specificsWithValues()
      keys.push(Specifics.KEY_LOOKUP[index])
      allValues.push(Specifics.HQMFJS[Specifics.FUNCTION_LOOKUP[index]](Specifics.PATIENT))
    cartesian = Specifics._generateCartisian(allValues)
    for values in cartesian
      occurrences = {}
      for key, i in keys
        occurrences[key] = values[i]
      row = new Row(occurrences)
      negatedRows.push(row) if !@hasRow(row)
    (new Specifics(negatedRows)).compactReusedEvents()

  @_generateCartisian: (allValues) ->
    Array::reduce.call(allValues, (as, bs) -> 
      product = []
      for a in as
        for b in bs
          product.push(a.concat(b))
      product
    , [[]])

  # removes any rows that have the save value for OccurrenceA and OccurrenceB
  compactReusedEvents: ->
    newRows = []
    for myRow in @rows
      goodRow = true
      for type,indexes of Specifics.TYPE_LOOKUP
        ids = []
        for index in indexes
          ids.push(myRow.values[index].id) if myRow.values[index] != Specifics.ANY
        goodRow &&= ids.length == ids.unique().length
      newRows.push(myRow) if goodRow
    new Specifics(newRows)
  
  hasRow: (row) ->
    found = false
    for myRow in @rows
      result = myRow.intersect(row)
      return true if result?
    return false
  
  hasRows: ->
    @rows.length > 0
  
  specificsWithValues: ->
    foundSpecificIndexes = []
    for row in @rows
      foundSpecificIndexes = foundSpecificIndexes.concat(row.specificsWithValues())
    foundSpecificIndexes.unique()
  
  hasSpecifics: ->
    anyHaveSpecifics = false
    for row in @rows
      anyHaveSpecifics ||= row.hasSpecifics()
    anyHaveSpecifics
  
  finalizeEvents: (eventsContext, boundsContext) ->
    result = this
    result = result.intersect(eventsContext) if (eventsContext?)
    result = result.intersect(boundsContext) if (boundsContext?)
    result.compactReusedEvents()
  
  group: (key) ->
    groupedRows = []
    for row in @rows
      groupedRows[row.groupKey(key)] = row
    groupedRows
    
  
  @validate: (populations...) ->
    value = Specifics.intersectAll(new Boolean(populations[0].isTrue()), populations)
    value.isTrue() and value.specificContext.hasRows()
  
  @intersectAll: (boolVal, values, negate=false) ->
    result = new Specifics()
    # add identity row
    result.addRows([new Row()])
    for value in values
      if value.specificContext?
        result = result.intersect(value.specificContext)
    if negate and (!result.hasRows() or result.hasSpecifics())
      result = result.negate()
      result = result.compactReusedEvents()
      # this is a little odd, but it appears when we have a negation with specifics we can ignore the logical result of the negation.
      # the reason we do this is because we may get too many negated values.  Values that may be culled later via other specific occurrences.  Thus we don't want to return 
      # false out of a negation because the values we are evaluating as false may be dropped.
      boolVal = new Boolean(true)
    boolVal.specificContext = result.compactReusedEvents()
    boolVal

  @unionAll: (boolVal, values,negate=false) ->
    result = new Specifics()
    for value in values
      if value.specificContext? and (value.isTrue() or negate)
        result = result.union(value.specificContext) if value.specificContext?
    
    if negate and result.hasSpecifics()
      result = result.negate() 
      # this is a little odd, but it appears when we have a negation with specifics we can ignore the logical result of the negation.  See comment in intersectAll.
      boolVal = new Boolean(true)
    boolVal.specificContext = result
    boolVal
  
  # copy the specifics parameters from an existing element onto the new value element
  @maintainSpecifics: (newElement, existingElement) ->
    newElement.specificContext = existingElement.specificContext
    newElement.specific_occurrence = existingElement.specific_occurrence
    newElement
    
@Specifics = Specifics

class Row
  # {'OccurrenceAEncounter':1, 'OccurrenceBEncounter'2}
  constructor: (occurrences={}) ->
    @length = Specifics.OCCURRENCES.length
    @values = []
    @tempValue = occurrences[undefined]
    for i in [0...@length]
      key = Specifics.KEY_LOOKUP[i]
      value = occurrences[key] || Specifics.ANY
      @values[i] = value

  hasSpecifics: ->
    @length = Specifics.OCCURRENCES.length
    foundSpecific = false
    for i in [0...@length]
      return true if @values[i] != Specifics.ANY
    false

  specificsWithValues: ->
    @length = Specifics.OCCURRENCES.length
    foundSpecificIndexes = []
    for i in [0...@length]
      foundSpecificIndexes.push(i) if @values[i]? and @values[i] != Specifics.ANY
    foundSpecificIndexes

  intersect: (other) ->
    intersectedRow = new Row({})
    allMatch = true
    for value,i in @values
      result = Row.match(value, other.values[i])
      if result?
        intersectedRow.values[i] = result 
      else
        return undefined
    intersectedRow
  
  groupKey: (key) ->
    keyForGroup = ''
    for i in [0...@length]
      keyForGroup += "#{@values[i].id}_" unless Specifics.KEY_LOOKUP[i] == key
    
  
  @match: (left, right) ->
    return right if left == Specifics.ANY
    return left if right == Specifics.ANY
    return left if left.id == right.id
    return undefined
  
  # build specific for an entry given matching rows (with temporal references)
  @buildRowsForMatching: (entryKey, entry, matchesKey, matches) ->
    rows = []
    for match in matches
      occurrences={}
      occurrences[entryKey] = entry
      occurrences[matchesKey] = match
      rows.push(new Row(occurrences))
    rows
    
  # build specific for a given entry (there are no temporal references)
  @buildForDataCriteria: (entryKey, entries) ->
    rows = []
    for entry in entries
      occurrences={}
      occurrences[entryKey] = entry
      rows.push(new Row(occurrences))
    rows
  
@Row = Row
  
###
  Wrap methods to maintain specificContext and specific_occurrence
###

hQuery.CodedEntryList::withStatuses = wrap(hQuery.CodedEntryList::withStatuses, (func, statuses, includeUndefined=true) ->
  context = this.specificContext
  occurrence = this.specific_occurrence
  func = bind(func, this)
  result = func(statuses,includeUndefined)
  result.specificContext = context
  result.specific_occurrence = occurrence
  return result;
);

hQuery.CodedEntryList::withNegation = wrap(hQuery.CodedEntryList::withNegation, (func, codeSet) ->
  context = this.specificContext
  occurrence = this.specific_occurrence
  func = bind(func, this)
  result = func(codeSet)
  result.specificContext = context
  result.specific_occurrence = occurrence
  return result;
);

hQuery.CodedEntryList::withoutNegation = wrap(hQuery.CodedEntryList::withoutNegation, (func) ->
  context = this.specificContext
  occurrence = this.specific_occurrence
  func = bind(func, this)
  result = func()
  result.specificContext = context
  result.specific_occurrence = occurrence
  return result;
);

hQuery.CodedEntryList::concat = wrap(hQuery.CodedEntryList::concat, (func, otherEntries) ->
  context = this.specificContext
  occurrence = this.specific_occurrence
  func = bind(func, this)
  result = func(otherEntries)
  result.specificContext = context
  result.specific_occurrence = occurrence
  return result;
);

hQuery.CodedEntryList::match = wrap(hQuery.CodedEntryList::match, (func, codeSet, start, end, includeNegated=false) ->
  context = this.specificContext
  occurrence = this.specific_occurrence
  func = bind(func, this)
  result = func(codeSet, start, end, includeNegated)
  result.specificContext = context
  result.specific_occurrence = occurrence
  return result;
);


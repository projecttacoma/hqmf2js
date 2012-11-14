@hqmf ||= {}

###
  {
    rows: [
      [1,3,5],
      [1,7,8],
    ]
  }

A singleton class the represents the table of all specific occurrences
###
class hqmf.SpecificsManagerSingleton
  constructor: ->
    @patient = null
    @any = '*'

  initialize: (patient, hqmfjs, occurrences...)->
    @occurrences = occurrences
    @keyLookup = {}
    @indexLookup = {}
    @typeLookup = {}
    @functionLookup = {}
    @patient = patient
    @hqmfjs = hqmfjs
    for occurrenceKey,i in occurrences
      @keyLookup[i] = occurrenceKey.id
      @indexLookup[occurrenceKey.id] = i
      @functionLookup[i] = occurrenceKey.function
      @typeLookup[occurrenceKey.type] ||= []
      @typeLookup[occurrenceKey.type].push(i)
  
  _generateCartisian: (allValues) ->
    _.reduce(allValues, (as, bs) -> 
      product = []
      for a in as
        for b in bs
          product.push(a.concat(b))
      product
    , [[]])
  
  identity: ->
    new hqmf.SpecificOccurrence([new Row(undefined)])

  extractEventsForLeftMost: (rows) ->
    events = []
    for row in rows
      events.push(@extractEvent(row.leftMost, row))
    events
  
  
  extractEvents: (key, rows) ->
    events = []
    for row in rows
      events.push(@extractEvent(key, row))
    events
    
  extractEvent: (key, row) ->
    index = @indexLookup[key]
    if index?
      entry = row.values[index]
    else
      entry = row.tempValue
    entry = new hQuery.CodedEntry(entry.json)
    entry.specificRow = row
    entry
  
  validate: (populations...) ->
    value = @intersectAll(new Boolean(populations[0].isTrue()), populations)
    value.isTrue() and value.specificContext.hasRows()
  
  intersectAll: (boolVal, values, negate=false) ->
    result = new hqmf.SpecificOccurrence
    # add identity row
    result.addIdentityRow()
    for value in values
      if value.specificContext?
        result = result.intersect(value.specificContext)
    if negate and (!result.hasRows() or result.hasSpecifics())
      result = result.negate()
      result = result.compactReusedEvents()
      # this is a little odd, but it appears when we have a negation with specifics we can ignore the logical result of the negation.
      # the reason we do this is because we may get too many negated values.  Values that may be culled later via other specific occurrences.  Thus we do not want to return 
      # false out of a negation because the values we are evaluating as false may be dropped.
      boolVal = new Boolean(true)
    boolVal.specificContext = result.compactReusedEvents()
    boolVal

  unionAll: (boolVal, values,negate=false) ->
    result = new hqmf.SpecificOccurrence
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
  maintainSpecifics: (newElement, existingElement) ->
    newElement.specificContext = existingElement.specificContext
    newElement.specific_occurrence = existingElement.specific_occurrence
    newElement
    
@hqmf.SpecificsManager = new hqmf.SpecificsManagerSingleton

class hqmf.SpecificOccurrence
  constructor: (rows=[])->
    @rows = rows
  
  addRows: (rows) ->
    @rows = @rows.concat(rows)
    
  removeDuplicateRows: () ->
    deduped = new hqmf.SpecificOccurrence
    for row in @rows
      # this could potentially be hasRow to dump even more rows.
      deduped.addRows([row]) if !deduped.hasExactRow(row)
    deduped
  
  hasExactRow: (other) ->
    for row in @rows
      return true if row.equals(other)
    return false
  
  union: (other) ->
    value = new hqmf.SpecificOccurrence()
    value.rows = @rows.concat(other.rows)
    value.removeDuplicateRows()
  
  intersect: (other) ->
    value = new hqmf.SpecificOccurrence()
    for leftRow in @rows
      for rightRow in other.rows
        result = leftRow.intersect(rightRow)
        value.rows.push(result) if result?
    value.removeDuplicateRows()
  
  getLeftMost: ->
    leftMost = undefined
    for row in @rows
      leftMost = row.leftMost unless leftMost?
      return undefined if leftMost != row.leftMost
    leftMost
  
  negate: ->
    negatedRows = []
    keys = []
    allValues = []
    for index in @specificsWithValues()
      keys.push(hqmf.SpecificsManager.keyLookup[index])
      allValues.push(hqmf.SpecificsManager.hqmfjs[hqmf.SpecificsManager.functionLookup[index]](hqmf.SpecificsManager.patient))
    cartesian = hqmf.SpecificsManager._generateCartisian(allValues)
    for values in cartesian
      occurrences = {}
      for key, i in keys
        occurrences[key] = values[i]
      row = new Row(@getLeftMost(), occurrences)
      negatedRows.push(row) if !@hasRow(row)
    (new hqmf.SpecificOccurrence(negatedRows)).compactReusedEvents()
    # removes any rows that have the same value for OccurrenceA and OccurrenceB
  compactReusedEvents: ->
    newRows = []
    for myRow in @rows
      goodRow = true
      for type,indexes of hqmf.SpecificsManager.typeLookup
        ids = []
        for index in indexes
          ids.push(myRow.values[index].id) if myRow.values[index] != hqmf.SpecificsManager.any
        goodRow &&= ids.length == _.unique(ids).length
      newRows.push(myRow) if goodRow
    new hqmf.SpecificOccurrence(newRows)
  
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
    _.unique(foundSpecificIndexes)
  
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
  
  group: ->
    groupedRows = {}
    for row in @rows
      groupedRows[row.groupKeyForLeftMost()] ||= []
      groupedRows[row.groupKeyForLeftMost()].push(row)
    groupedRows
    
  COUNT: (range) ->
    @applyRangeSubset(COUNT, range)

  MIN: (range) ->
    @applyRangeSubset(MIN, range)

  MAX: (range) ->
    @applyRangeSubset(MAX, range)
    
  applyRangeSubset: (func, range) ->
    return this if !@hasSpecifics()
    resultRows = []
    groupedRows = @group()
    for groupKey, group of groupedRows
      if func(hqmf.SpecificsManager.extractEventsForLeftMost(group), range).isTrue()
        resultRows = resultRows.concat(group)
    new hqmf.SpecificOccurrence(resultRows)

  FIRST: ->
    @applySubset(FIRST)

  SECOND: ->
    @applySubset(SECOND)

  THIRD: ->
    @applySubset(THIRD)

  FOURTH: ->
    @applySubset(FOURTH)

  FIFTH: ->
    @applySubset(FIFTH)

  LAST: ->
    @applySubset(LAST)

  RECENT: ->
    @applySubset(RECENT)
    
  applySubset: (func) ->
    return this if !@hasSpecifics()
    resultRows = []
    groupedRows = @group()
    for groupKey, group of groupedRows
      entries = func(hqmf.SpecificsManager.extractEventsForLeftMost(group))
      if entries.length > 0
        resultRows.push(entries[0].specificRow)
    new hqmf.SpecificOccurrence(resultRows)
  
  addIdentityRow: ->
    @addRows(hqmf.SpecificsManager.identity().rows)



class Row
  # {'OccurrenceAEncounter':1, 'OccurrenceBEncounter'2}
  constructor: (leftMost, occurrences={}) ->
    throw "left most key must be a string or undefined was: #{leftMost}" if typeof(leftMost) != 'string' and typeof(leftMost) != 'undefined'
    @length = hqmf.SpecificsManager.occurrences.length
    @values = []
    @leftMost = leftMost
    @tempValue = occurrences[undefined]
    for i in [0...@length]
      key = hqmf.SpecificsManager.keyLookup[i]
      value = occurrences[key] || hqmf.SpecificsManager.any
      @values[i] = value

  hasSpecifics: ->
    @length = hqmf.SpecificsManager.occurrences.length
    foundSpecific = false
    for i in [0...@length]
      return true if @values[i] != hqmf.SpecificsManager.any
    false

  specificsWithValues: ->
    @length = hqmf.SpecificsManager.occurrences.length
    foundSpecificIndexes = []
    for i in [0...@length]
      foundSpecificIndexes.push(i) if @values[i]? and @values[i] != hqmf.SpecificsManager.any
    foundSpecificIndexes

  equals: (other) ->
    equal = true;
    
    equal &&= Row.valuesEqual(@tempValue, other.tempValue)
    for value,i in @values
      equal &&= Row.valuesEqual(value, other.values[i])
    equal

  intersect: (other) ->
    intersectedRow = new Row(@leftMost, {})
    intersectedRow.tempValue = @tempValue
    allMatch = true
    for value,i in @values
      result = Row.match(value, other.values[i])
      if result?
        intersectedRow.values[i] = result 
      else
        return undefined
    intersectedRow
  
  groupKeyForLeftMost: ->
    @groupKey(@leftMost)
    
  groupKey: (key=null) ->
    keyForGroup = ''
    for i in [0...@length]
      value = hqmf.SpecificsManager.any
      value = @values[i].id if @values[i] != hqmf.SpecificsManager.any 
      if hqmf.SpecificsManager.keyLookup[i] == key
        keyForGroup += "X_"
      else
        keyForGroup += "#{value}_"
    keyForGroup
    
  
  @match: (left, right) ->
    return right if left == hqmf.SpecificsManager.any
    return left if right == hqmf.SpecificsManager.any
    return left if left.id == right.id
    return undefined

  @valuesEqual: (left, right) ->
    return true if !left? and !right?
    return false if !left?
    return false if !right?
    return true if left == hqmf.SpecificsManager.any and right == hqmf.SpecificsManager.any
    return true if left.id == right.id
    return false
  
  # build specific for an entry given matching rows (with temporal references)
  @buildRowsForMatching: (entryKey, entry, matchesKey, matches) ->
    rows = []
    for match in matches
      occurrences={}
      occurrences[entryKey] = entry
      occurrences[matchesKey] = match
      rows.push(new Row(entryKey, occurrences))
    rows
    
  # build specific for a given entry (there are no temporal references)
  @buildForDataCriteria: (entryKey, entries) ->
    rows = []
    for entry in entries
      occurrences={}
      occurrences[entryKey] = entry
      rows.push(new Row(entryKey, occurrences))
    rows
  
@Row = Row
  
###
  Wrap methods to maintain specificContext and specific_occurrence
###

hQuery.CodedEntryList::withStatuses = _.wrap(hQuery.CodedEntryList::withStatuses, (func, statuses, includeUndefined=true) ->
  context = this.specificContext
  occurrence = this.specific_occurrence
  func = _.bind(func, this)
  result = func(statuses,includeUndefined)
  result.specificContext = context
  result.specific_occurrence = occurrence
  return result;
);

hQuery.CodedEntryList::withNegation = _.wrap(hQuery.CodedEntryList::withNegation, (func, codeSet) ->
  context = this.specificContext
  occurrence = this.specific_occurrence
  func = _.bind(func, this)
  result = func(codeSet)
  result.specificContext = context
  result.specific_occurrence = occurrence
  return result;
);

hQuery.CodedEntryList::withoutNegation = _.wrap(hQuery.CodedEntryList::withoutNegation, (func) ->
  context = this.specificContext
  occurrence = this.specific_occurrence
  func = _.bind(func, this)
  result = func()
  result.specificContext = context
  result.specific_occurrence = occurrence
  return result;
);

hQuery.CodedEntryList::concat = _.wrap(hQuery.CodedEntryList::concat, (func, otherEntries) ->
  context = this.specificContext
  occurrence = this.specific_occurrence
  func = _.bind(func, this)
  result = func(otherEntries)
  result.specificContext = context
  result.specific_occurrence = occurrence
  return result;
);

hQuery.CodedEntryList::match = _.wrap(hQuery.CodedEntryList::match, (func, codeSet, start, end, includeNegated=false) ->
  context = this.specificContext
  occurrence = this.specific_occurrence
  func = _.bind(func, this)
  result = func(codeSet, start, end, includeNegated)
  result.specificContext = context
  result.specific_occurrence = occurrence
  return result;
);


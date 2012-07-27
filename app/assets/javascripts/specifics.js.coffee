
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
  @INITIALIZED: false
  @ANY = '*'
  
  @initialize: (occurrences...)->
    Specifics.OCCURRENCES = occurrences
    Specifics.KEY_LOOKUP = {}
    for occurrenceKey,i in occurrences
      Specifics.KEY_LOOKUP[i] = occurrenceKey
  
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
  
  finalizeEvents: (eventsContext, boundsContext) ->
    result = this
    result = result.intersect(eventsContext) if (eventsContext?)
    result = result.intersect(boundsContext) if (boundsContext?)
    result

class Row
  # {'OccurrenceAEncounter':1, 'OccurrenceBEncounter'2}
  constructor: (occurrences={}) ->
    @length = Specifics.OCCURRENCES.length
    @values = []
    for i in [0..@length]
      key = Specifics.KEY_LOOKUP[i]
      value = occurrences[key] || Specifics.ANY
      @values[i] = value
  
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
  
  @match: (left, right) ->
    return right if left == Specifics.ANY
    return left if right == Specifics.ANY
    return left if left.id == right.id
    return undefined
  
  @buildRows: (entryKey, entry, matchesKey, matches) ->
    rows = []
    for match in matches
      occurrences={}
      occurrences[entryKey] = entry
      occurrences[matchesKey] = match
      rows.push(new Row(occurrences))
    rows
  

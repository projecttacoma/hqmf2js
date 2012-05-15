class @TS  
  constructor: (hl7ts) ->
    if hl7ts
      year = parseInt(hl7ts.substring(0, 4))
      month = parseInt(hl7ts.substring(4, 6), 10)-1
      day = parseInt(hl7ts.substring(6, 8), 10)
      @date = new Date(year, month, day)
    else
      @date = new Date()
  add: (pq) ->
    if pq.unit=="a"
      @date.setFullYear(@date.getFullYear()+pq.value)
    else if pq.unit=="mo"
      @date.setMonth(@date.getMonth()+pq.value)
    else if pq.unit=="d"
      @date.setDate(@date.getDate()+pq.value)
    else if pq.unit=="h"
      @date.setHours(@date.getHours()+pq.value)
    else if pq.unit=="min"
      @date.setMinutes(@date.getMinutes()+pq.value)
    else
      throw "Unknown time unit: "+pq.unit
    this
  asDate: ->
    @date
  before: (other) -> @date.getTime() < other.date.getTime()
  after: (other) ->  @date.getTime() > other.date.getTime()
  beforeOrConcurrent: (other) ->  @date.getTime() <= other.date.getTime()
  afterOrConcurrent: (other) -> @date.getTime() >= other.date.getTime()
  
class @CD
	constructor: (@code) ->
	code: ->
	  @code
	match: (val) ->
	  @code==val
	
class @PQ
	constructor: (@value, @unit) ->
	unit: -> @unit
	value: -> @value
	lessThan: (val) ->
	  @value<val
	greaterThan: (val) ->
	  @value>val
	match: (val) ->
	  @value==val
	
class @IVL
  constructor: (@low_pq, @high_pq) ->
  match: (val) ->
    (!@low_pq? || @low_pq.lessThan(val)) && (!@high_pq? || @high_pq.greaterThan(val))
    
class @IVL_TS
  constructor: (@low, @high) ->
  add: (pq) ->
    @low.add(pq)
    @high.add(pq)
    this
  DURING: (other) -> @low.afterOrConcurrent(other.low) && @high.beforeOrConcurrent(other.high)
  SBS: (other) -> @low.before(other.low)
  SAS: (other) -> @low.after(other.low)
  SBE: (other) -> @low.before(other.high)
  SAE: (other) -> @low.after(other.high)
  EBS: (other) -> @high.before(other.low)
  EAS: (other) -> @high.after(other.low)
  EBE: (other) -> @high.before(other.high)
  EAE: (other) -> @high.after(other.high)
	
@atLeastOneTrue = (values...) ->
  trueValues = (value for value in values when value && (value==true || value.length!=0))
  trueValues.length>0
  
@allTrue = (values...) ->
  trueValues = (value for value in values when value && (value==true || value.length!=0))
  trueValues.length>0 && trueValues.length==values.length
  
@matchingValue = (value, compareTo) ->
  compareTo.match(value)

@filterEventsByValue = (events, value) ->
  matchingValues = (event for event in events when (event.value && value.match(event.value().scalar)))
  matchingValues

@getCodes = (oid) ->
  OidDictionary[oid]

@PREVSUM = (eventList) ->
  eventList

@RECENT = (events) ->
  dateSortDescending = (a, b) ->
    b.json.time - a.json.time
  [events.sort(dateSortDescending)[0]]
  
@eventMatchesBounds = (event, bounds, methodName, offset) ->
  eventTS = event.asIVL_TS()
  matchingBounds = (bound for bound in bounds when (
    boundTS = bound.asIVL_TS()
    if offset
      boundTS.add(offset)
    eventTS[methodName](boundTS)
  ))
  matchingBounds && matchingBounds.length>0

@DURING = (events, bounds, offset) ->
  if (bounds.length==undefined)
    bounds = [bounds]
  matchingEvents = (event for event in events when (
    eventMatchesBounds(event, bounds, "DURING", offset)
  ))
  matchingEvents

@SBS = (events, bounds, offset) ->
  if (bounds.length==undefined)
    bounds = [bounds]
  matchingEvents = (event for event in events when (
    eventMatchesBounds(event, bounds, "SBS", offset)
  ))
  matchingEvents

@OidDictionary = {};
@hqmfjs = @hqmfjs||{};

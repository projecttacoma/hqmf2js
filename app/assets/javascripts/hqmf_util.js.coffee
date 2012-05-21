class @TS  
  constructor: (hl7ts, @inclusive=false) ->
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
  before: (other) -> 
    if other.inclusive
      beforeOrConcurrent(other)
    else
      @date.getTime() < other.date.getTime()
  after: (other) ->
    if other.inclusive
      afterOrConcurrent(other)
    else
      @date.getTime() > other.date.getTime()
  beforeOrConcurrent: (other) ->  @date.getTime() <= other.date.getTime()
  afterOrConcurrent: (other) -> @date.getTime() >= other.date.getTime()
  
class @CD
	constructor: (@code) ->
	code: ->
	  @code
	match: (val) ->
	  @code==val
	
class @PQ
	constructor: (@value, @unit, @inclusive=false) ->
	lessThan: (val) ->
	  @value<val
	greaterThan: (val) ->
	  @value>val
	lessThanOrEqual: (val) ->
	  @value<=val
	greaterThanOrEqual: (val) ->
	  @value>=val
	match: (val) ->
	  @value==val
	
class @IVL_PQ
  constructor: (@low_pq, @high_pq) ->
  match: (val) ->
    (!@low_pq? || @low_pq.lessThan(val)) && (!@high_pq? || @high_pq.greaterThan(val))
  matchInclusive: (val) ->
    (!@low_pq? || @low_pq.lessThanOrEqual(val)) && (!@high_pq? || @high_pq.greaterThanOrEqual(val))
    
class @IVL_TS
  constructor: (@low, @high) ->
  add: (pq) ->
    @low.add(pq)
    @high.add(pq)
    this
  DURING: (other) -> this.SDU(other) || this.EDU(other) || (this.SBS(other) && this.EAE(other))
  SBS: (other) -> @low.before(other.low)
  SAS: (other) -> @low.after(other.low)
  SBE: (other) -> @low.before(other.high)
  SAE: (other) -> @low.after(other.high)
  EBS: (other) -> @high.before(other.low)
  EAS: (other) -> @high.after(other.low)
  EBE: (other) -> @high.before(other.high)
  EAE: (other) -> @high.after(other.high)
  SDU: (other) -> @low.afterOrConcurrent(other.low) && @low.beforeOrConcurrent(other.high)
  EDU: (other) -> @high.afterOrConcurrent(other.low) && @high.beforeOrConcurrent(other.high)
  ECW: (other) -> @high.asDate().getTime() == other.high.asDate().getTime()
  SCW: (other) -> @low.asDate().getTime() == other.low.asDate().getTime()
  CONCURRENT: (other) -> this.SCW(other) && this.ECW(other)
	
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

@UNION = (eventLists...) ->
  union = []
  for eventList in eventLists
    union=union.concat(eventList)
  union

@COUNT = (events, range) ->
  count = events.length
  range.matchInclusive(count)

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
  
@eventsMatchBounds = (events, bounds, methodName, offset) ->
  if (bounds.length==undefined)
    bounds = [bounds]
  if (events.length==undefined)
    events = [events]
  matchingEvents = (event for event in events when (
    eventMatchesBounds(event, bounds, methodName, offset)
  ))
  matchingEvents
  
@DURING = (events, bounds, offset) ->
  eventsMatchBounds(events, bounds, "DURING", offset)

@SBS = (events, bounds, offset) ->
  eventsMatchBounds(events, bounds, "SBS", offset)

@SAS = (events, bounds, offset) ->
  eventsMatchBounds(events, bounds, "SAS", offset)

@SBE = (events, bounds, offset) ->
  eventsMatchBounds(events, bounds, "SBE", offset)

@SAE = (events, bounds, offset) ->
  eventsMatchBounds(events, bounds, "SAE", offset)

@EBS = (events, bounds, offset) ->
  eventsMatchBounds(events, bounds, "EBS", offset)

@EAS = (events, bounds, offset) ->
  eventsMatchBounds(events, bounds, "EAS", offset)

@EBE = (events, bounds, offset) ->
  eventsMatchBounds(events, bounds, "EBE", offset)

@EAE = (events, bounds, offset) ->
  eventsMatchBounds(events, bounds, "EAE", offset)

@SDU = (events, bounds, offset) ->
  eventsMatchBounds(events, bounds, "SDU", offset)

@EDU = (events, bounds, offset) ->
  eventsMatchBounds(events, bounds, "EDU", offset)

@ECW = (events, bounds, offset) ->
  eventsMatchBounds(events, bounds, "ECW", offset)

@SCW = (events, bounds, offset) ->
  eventsMatchBounds(events, bounds, "SCW", offset)

@CONCURRENT = (events, bounds, offset) ->
  eventsMatchBounds(events, bounds, "CONCURRENT", offset)

@OidDictionary = {};
@hqmfjs = @hqmfjs||{};

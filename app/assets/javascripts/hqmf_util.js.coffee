class TS
  constructor: (hl7ts, @inclusive=false) ->
    if hl7ts
      year = parseInt(hl7ts.substring(0, 4))
      month = parseInt(hl7ts.substring(4, 6), 10)-1
      day = parseInt(hl7ts.substring(6, 8), 10)
      hour = parseInt(hl7ts.substring(8, 10), 10)
      if isNaN(hour)
        hour = 0
      minute = parseInt(hl7ts.substring(10,12), 10)
      if isNaN(minute)
        minute = 0
      @date = new Date(year, month, day, hour, minute)
    else
      @date = new Date()
  add: (pq) ->
    if pq.unit=="a"
      @date.setFullYear(@date.getFullYear()+pq.value)
    else if pq.unit=="mo"
      @date.setMonth(@date.getMonth()+pq.value)
    else if pq.unit=="wk"
      @date.setDate(@date.getDate()+(7*pq.value))
    else if pq.unit=="d"
      @date.setDate(@date.getDate()+pq.value)
    else if pq.unit=="h"
      @date.setHours(@date.getHours()+pq.value)
    else if pq.unit=="min"
      @date.setMinutes(@date.getMinutes()+pq.value)
    else
      throw "Unknown time unit: "+pq.unit
    this
  difference: (ts, granularity) ->
    earlier = later = null
    if @afterOrConcurrent(ts)
      earlier = ts.asDate()
      later = @date
    else
      earlier = @date
      later = ts.asDate()
    if granularity=="a"
      @yearsDifference(earlier,later)
    else if granularity=="mo"
      @monthsDifference(earlier,later)
    else if granularity=="wk"
      @weeksDifference(earlier,later)
    else if granularity=="d"
      @daysDifference(earlier,later)
    else if granularity=="h"
      @hoursDifference(earlier,later)
    else if granularity=="min"
      @minutesDifference(earlier,later)
    else
      throw "Unknown time unit: "+granularity
  yearsDifference: (earlier, later) ->
    if (later.getMonth() < earlier.getMonth())
      later.getFullYear()-earlier.getFullYear()-1
    else if (later.getMonth() == earlier.getMonth() && later.getDate() >= earlier.getDate())
      later.getFullYear()-earlier.getFullYear()
    else if (later.getMonth() == earlier.getMonth() && later.getDate() < earlier.getDate())
      later.getFullYear()-earlier.getFullYear()-1
    else
      later.getFullYear()-earlier.getFullYear()
  monthsDifference: (earlier, later) ->
    if (later.getDate() >= earlier.getDate())
      (later.getFullYear()-earlier.getFullYear())*12+later.getMonth()-earlier.getMonth()
    else
      (later.getFullYear()-earlier.getFullYear())*12+later.getMonth()-earlier.getMonth()-1
  minutesDifference: (earlier, later) ->
    Math.floor(((later.getTime()-earlier.getTime())/1000)/60)
  hoursDifference: (earlier, later) ->
    Math.floor(@minutesDifference(earlier,later)/60)
  daysDifference: (earlier, later) ->
    # have to discard time portion for day difference calculation purposes
    e = new Date(earlier.getFullYear(), earlier.getMonth(), earlier.getDate())
    e.setUTCHours(0)
    l = new Date(later.getFullYear(), later.getMonth(), later.getDate())
    l.setUTCHours(0)
    Math.floor(@hoursDifference(e,l)/24)
  weeksDifference: (earlier, later) ->
    Math.floor(@daysDifference(earlier,later)/7)
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
@TS = TS
  
class CD
	constructor: (@code) ->
	code: ->
	  @code
	match: (val) ->
	  @code==val
@CD = CD
	
class PQ
	constructor: (@value, @unit, @inclusive=true) ->
	lessThan: (val) ->
	  if @inclusive
	    @lessThanOrEqual(val)
	  else
	    @value<val
	greaterThan: (val) ->
	  if @inclusive
	    @greaterThanOrEqual(val)
	  else
  	  @value>val
	lessThanOrEqual: (val) ->
	  @value<=val
	greaterThanOrEqual: (val) ->
	  @value>=val
	match: (val) ->
	  @value==val
@PQ = PQ
	
class IVL_PQ
  constructor: (@low_pq, @high_pq) ->
    if !@low_pq && !@high_pq
      throw "Must have a lower or upper bound"
    if @low_pq && @low_pq.unit && @high_pq && @high_pq.unit && @low_pq.unit != @high_pq.unit
      throw "Mismatched low and high units: "+@low_pq.unit+", "+@high_pq.unit
  unit: ->
    if @low_pq
      @low_pq.unit
    else
      @high_pq.unit
  match: (val) ->
    (!@low_pq? || @low_pq.lessThan(val)) && (!@high_pq? || @high_pq.greaterThan(val))
@IVL_PQ = IVL_PQ
    
class IVL_TS
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
@IVL_TS = IVL_TS
	
atLeastOneTrue = (values...) ->
  trueValues = (value for value in values when value && (value==true || value.length!=0))
  trueValues.length>0
@atLeastOneTrue = atLeastOneTrue
  
allTrue = (values...) ->
  trueValues = (value for value in values when value && (value==true || value.length!=0))
  trueValues.length>0 && trueValues.length==values.length
@allTrue = allTrue
  
matchingValue = (value, compareTo) ->
  compareTo.match(value)
@matchingValue = matchingValue

filterEventsByValue = (events, value) ->
  matchingValues = (event for event in events when (event.value && value.match(event.value().scalar)))
  matchingValues
@filterEventsByValue = filterEventsByValue

getCodes = (oid) ->
  OidDictionary[oid]
@getCodes = getCodes

class CrossProductIterator
  constructor: (@crossProduct) ->
    @positions = []
    for eventList in @crossProduct.eventLists
      @positions.push(0)
  hasNext: ->
    if @positions.length==0
      return false
    available = true
    for position, i in @positions
      if position >= @crossProduct.eventLists[i].length
        available = false
    available
  next: ->
    throw "No more entries" if !this.hasNext()
    combination = []
    moved = false
    for position, i in @positions
      combination.push @crossProduct.eventLists[i][position]
      if !moved && position < @crossProduct.eventLists[i].length-1
        @positions[i] = position+1
        moved = true
    # if we weren't able to move to a new valid position then move off end
    if !moved
      @positions[0] = @positions[0] + 1
    combination

class CrossProduct extends Array
  constructor: (eventLists) ->
    super()
    @eventLists = []
    for eventList in eventLists
      if eventList.length > 0
        @eventLists.push eventList
        for event in eventList
          this.push(event)
  iterator: ->
    new CrossProductIterator(this)

XPRODUCT = (eventLists...) ->
  new CrossProduct(eventLists)
@XPRODUCT = XPRODUCT

UNION = (eventLists...) ->
  union = []
  for eventList in eventLists
    for event in eventList
      union.push(event)
  union
@UNION = UNION

COUNT = (events, range) ->
  count = events.length
  range.match(count)
@COUNT = COUNT

PREVSUM = (eventList) ->
  eventList
@PREVSUM = PREVSUM

getIVL = (eventOrTimeStamp) ->
  if eventOrTimeStamp.asIVL_TS
    eventOrTimeStamp.asIVL_TS()
  else
    ts = new TS()
    ts.date = eventOrTimeStamp
    new IVL_TS(ts, ts)
@getIVL = getIVL
    
# should DURING and CONCURRENT be an error ?
eventAccessor = {  
  'DURING': 'low',
  'SBS': 'low',
  'SAS': 'low',
  'SBE': 'low',
  'SAE': 'low',
  'EBS': 'high',
  'EAS': 'high',
  'EBE': 'high',
  'EAE': 'high',
  'SDU': 'low',
  'EDU': 'high',
  'ECW': 'high'
  'SCW': 'low',
  'CONCURRENT': 'low'
}

# should DURING SDU, EDU, ECW, SCW and CONCURRENT be an error ?
boundAccessor = {  
  'DURING': 'low',
  'SBS': 'low',
  'SAS': 'low',
  'SBE': 'high',
  'SAE': 'high',
  'EBS': 'low',
  'EAS': 'low',
  'EBE': 'high',
  'EAE': 'high',
  'SDU': 'low',
  'EDU': 'low',
  'ECW': 'low'
  'SCW': 'low',
  'CONCURRENT': 'low'
}
    
withinRange = (method, eventIVL, boundIVL, range) ->
  eventTS = eventIVL[eventAccessor[method]]
  boundTS = boundIVL[boundAccessor[method]]
  range.match(eventTS.difference(boundTS, range.unit()))
@withinRange = withinRange
    
eventMatchesBounds = (event, bounds, methodName, range) ->
  eventIVL = getIVL(event)
  matchingBounds = []
  if bounds.iterator
    iterator = bounds.iterator()
    while iterator.hasNext()
      boundList = iterator.next()
      matchesAllInBoundList = true
      for bound in boundList
        boundIVL = getIVL(bound)
        if !eventIVL[methodName](boundIVL)
          matchesAllInBoundList = false
        if matchesAllInBoundList && range
          matchesAllInBoundList = withinRange(methodName, eventIVL, boundIVL, range)
      if matchesAllInBoundList
        matchingBounds.push(boundList)
  else
    matchingBounds = (bound for bound in bounds when (
      boundIVL = getIVL(bound)
      result = eventIVL[methodName](boundIVL)
      if range
        result &&= withinRange(methodName, eventIVL, boundIVL, range)
      result
    ))
  matchingBounds && matchingBounds.length>0
@eventMatchesBounds = eventMatchesBounds
  
eventsMatchBounds = (events, bounds, methodName, range) ->
  if (bounds.length==undefined)
    bounds = [bounds]
  if (events.length==undefined)
    events = [events]
  matchingEvents = (event for event in events when (
    eventMatchesBounds(event, bounds, methodName, range)
  ))
  matchingEvents
@eventsMatchBounds = eventsMatchBounds
  
DURING = (events, bounds, offset) ->
  eventsMatchBounds(events, bounds, "DURING", offset)
@DURING = DURING

SBS = (events, bounds, offset) ->
  eventsMatchBounds(events, bounds, "SBS", offset)
@SBS = SBS

SAS = (events, bounds, offset) ->
  eventsMatchBounds(events, bounds, "SAS", offset)
@SAS = SAS

SBE = (events, bounds, offset) ->
  eventsMatchBounds(events, bounds, "SBE", offset)
@SBE = SBE

SAE = (events, bounds, offset) ->
  eventsMatchBounds(events, bounds, "SAE", offset)
@SAE = SAE

EBS = (events, bounds, offset) ->
  eventsMatchBounds(events, bounds, "EBS", offset)
@EBS = EBS

EAS = (events, bounds, offset) ->
  eventsMatchBounds(events, bounds, "EAS", offset)
@EAS = EAS

EBE = (events, bounds, offset) ->
  eventsMatchBounds(events, bounds, "EBE", offset)
@EBE = EBE

EAE = (events, bounds, offset) ->
  eventsMatchBounds(events, bounds, "EAE", offset)
@EAE = EAE

SDU = (events, bounds, offset) ->
  eventsMatchBounds(events, bounds, "SDU", offset)
@SDU = SDU

EDU = (events, bounds, offset) ->
  eventsMatchBounds(events, bounds, "EDU", offset)
@EDU = EDU

ECW = (events, bounds, offset) ->
  eventsMatchBounds(events, bounds, "ECW", offset)
@ECW = ECW
  
SCW = (events, bounds, offset) ->
  eventsMatchBounds(events, bounds, "SCW", offset)
@SCW = SCW

CONCURRENT = (events, bounds, offset) ->
  eventsMatchBounds(events, bounds, "CONCURRENT", offset)
@CONCURRENT = CONCURRENT

dateSortDescending = (a, b) ->
  b.timeStamp().getTime() - a.timeStamp().getTime()
@dateSortDescending= dateSortDescending

dateSortAscending = (a, b) ->
  a.timeStamp().getTime() - b.timeStamp().getTime()
@dateSortAscending = dateSortAscending

FIRST = (events) ->
  if (events.length > 0)
    [events.sort(dateSortAscending)[0]]
  else
    []
@FIRST = FIRST

SECOND = (events) ->
  if (events.length > 1)
    [events.sort(dateSortAscending)[1]]
  else
    []
@SECOND = SECOND

THIRD = (events) ->
  if (events.length > 2)
    [events.sort(dateSortAscending)[2]]
  else
    []
@THIRD = THIRD

FOURTH = (events) ->
  if (events.length > 3)
    [events.sort(dateSortAscending)[3]]
  else
    []
@FOURTH = FOURTH

FIFTH = (events) ->
  if (events.length > 4)
    [events.sort(dateSortAscending)[4]]
  else
    []
@FIFTH = FIFTH

RECENT = (events) ->
  if (events.length > 0)
    [events.sort(dateSortDescending)[0]]
  else
    []
@RECENT = RECENT
  
LAST = (events) ->
  RECENT(events)
@LAST = LAST
  
valueSortDescending = (a, b) ->
  va = vb = Infinity
  if a.value
    va = a.value()["scalar"]
  if b.value 
    vb = b.value()["scalar"]
  if va==vb
    0
  else
    vb - va
@valueSortDescending = valueSortDescending

valueSortAscending = (a, b) ->
  va = vb = Infinity
  if a.value
    va = a.value()["scalar"]
  if b.value 
    vb = b.value()["scalar"]
  if va==vb
    0
  else
    va - vb
@valueSortAscending = valueSortAscending

MIN = (events, range) ->
  minValue = Infinity
  if (events.length > 0)
    minValue = events.sort(valueSortAscending)[0].value()["scalar"]
  range.match(minValue)
@MIN = MIN

MAX = (events, range) ->
  maxValue = -Infinity
  if (events.length > 0)
    maxValue = events.sort(valueSortDescending)[0].value()["scalar"]
  range.match(maxValue)
@MAX = MAX

@OidDictionary = {};

hqmfjs = hqmfjs||{}
@hqmfjs = @hqmfjs||{};

hQuery.Patient::procedureResults = -> this.results().concat(this.vitalSigns()).concat(this.procedures())
hQuery.Patient::allProcedures = -> this.procedures().concat(this.immunizations()).concat(this.medications())
hQuery.Patient::laboratoryTests = -> this.results().concat(this.vitalSigns())
hQuery.Patient::allMedications = -> this.medications().concat(this.immunizations())
hQuery.Patient::allProblems = -> this.conditions().concat(this.socialHistories()).concat(this.procedures())
hQuery.Patient::allDevices = -> this.conditions().concat(this.procedures()).concat(this.careGoals()).concat(this.medicalEquipment())
hQuery.Patient::activeDiagnoses = -> this.conditions().concat(this.socialHistories()).withStatuses(['active'])
hQuery.Patient::inactiveDiagnoses = -> this.conditions().concat(this.socialHistories()).withStatuses(['inactive'])
hQuery.Patient::resolvedDiagnoses = -> this.conditions().concat(this.socialHistories()).withStatuses(['resolved'])
hQuery.Patient::getAndCacheEvents = (key, that, fn, args...) ->
  this.cache ||= {}
  if !this.cache[key]
    this.cache[key] = fn.apply(that, args)
  this.cache[key]
hQuery.Patient::getEvents = (eventCriteria) ->
  cacheKey = eventCriteria.type
  events = this.getAndCacheEvents(cacheKey, this, this[eventCriteria.type])
  if eventCriteria.statuses && eventCriteria.statuses.length > 0
    cacheKey = cacheKey + "_" + String(eventCriteria.statuses)
    events = this.getAndCacheEvents(cacheKey, events, events.withStatuses, eventCriteria.statuses, eventCriteria.includeEventsWithoutStatus)
  cacheKey = cacheKey + "_" + String(eventCriteria.negated) + String(eventCriteria.negationValueSetId)
  if eventCriteria.negated
    codes = getCodes(eventCriteria.negationValueSetId)
    events = this.getAndCacheEvents(cacheKey, events, events.withNegation, codes)
  else
    events = this.getAndCacheEvents(cacheKey, events, events.withoutNegation)
  if eventCriteria.valueSetId
    cacheKey = cacheKey + "_" + String(eventCriteria.valueSetId) + "_" + String(eventCriteria.start) + "_" + String(eventCriteria.stop)
    codes = getCodes(eventCriteria.valueSetId)
    events = this.getAndCacheEvents(cacheKey, events, events.match, codes, eventCriteria.start, eventCriteria.stop, true)
  else if eventCriteria.valueSet
    events = events.match(eventCriteria.valueSet, eventCriteria.start, eventCriteria.stop, true)
  events = events.slice(0) # clone cached array before we add on specific occurrence
  if eventCriteria.specificOccurrence
    events.specific_occurrence = eventCriteria.specificOccurrence
  events
  
hQuery.CodedEntry::asIVL_TS = ->
  tsLow = new TS()
  tsLow.date = this.startDate() || this.date() || null
  tsHigh = new TS()
  tsHigh.date = this.endDate() || this.date() || null
  new IVL_TS(tsLow, tsHigh)
hQuery.CodedEntry::asTS = ->
  ts = new TS()
  ts.date = this.timeStamp()
  ts

hQuery.Encounter::lengthOfStay = (unit) ->
  ivl_ts = this.asIVL_TS()
  ivl_ts.low.difference(ivl_ts.high, unit)

hQuery.CodedEntry::respondTo = (functionName) ->
  typeof(@[functionName]) == "function"

hQuery.CodedEntryList::isTrue = ->
  @length != 0

hQuery.CodedEntryList::isFalse = ->
  @length == 0

Array::isTrue = ->
  @length != 0

Array::isFalse = ->
  @length == 0

Boolean::isTrue = =>
  `this == true`
  
Boolean::isFalse = =>
  `this == false`

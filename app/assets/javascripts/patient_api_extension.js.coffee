hQuery.Patient::procedureResults = -> this.results().concat(this.vitalSigns()).concat(this.procedures())
hQuery.Patient::allProcedures = -> this.procedures().concat(this.immunizations()).concat(this.medications())
hQuery.Patient::laboratoryTests = -> this.results().concat(this.vitalSigns())
hQuery.Patient::allMedications = -> this.medications().concat(this.immunizations())
hQuery.Patient::allProblems = -> this.conditions().concat(this.socialHistories()).concat(this.procedures())
hQuery.Patient::allDevices = -> this.conditions().concat(this.procedures()).concat(this.careGoals()).concat(this.medicalEquipment())
hQuery.Patient::activeDiagnoses = -> this.conditions().concat(this.socialHistories()).withStatuses(['active'])
hQuery.Patient::inactiveDiagnoses = -> this.conditions().concat(this.socialHistories()).withStatuses(['inactive'])
hQuery.Patient::resolvedDiagnoses = -> this.conditions().concat(this.socialHistories()).withStatuses(['resolved'])
hQuery.Patient::getEvents = (type, statuses, includeUndefinedStatus, negated, negationCodes, codes, startDate, endDate) ->
  events = this[type]()
  if statuses && statuses.length > 0
    events = events.withStatuses(statuses, includeUndefinedStatus)
  if negated
    events = events.withNegation(negationCodes)
  else
    events = events.withoutNegation()
  if codes
    events = events.match(codes, startDate, endDate, true)
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

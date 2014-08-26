class @CrosswalkManager
  @matchedSystems: {}
  @trueMatchedSystems: {}
  @tmpTrueMatchedSystems: {}
  @clearValidateCodeSystemData: () ->
    CrosswalkManager.matchedSystems = {}
    CrosswalkManager.trueMatchedSystems = {}
    CrosswalkManager.tmpTrueMatchedSystems = {}

hQuery.Patient::validateCodeSystems = () ->
  sections = ['encounters','medications','conditions','procedures','results','vitalSigns','immunizations','allergies','pregnancies','socialHistories','careGoals','medicalEquipment','functionalStatuses']
  fullMatch = true
  for section in sections
    for entry in this[section]()
      matchedSystems = CrosswalkManager.matchedSystems[entry.id]
      if (matchedSystems? && _.keys(matchedSystems).length > 0)
        matches = _.keys(entry.json.codes).length == _.keys(matchedSystems).length
        fullMatch = fullMatch && matches
        Logger.info("#{entry.json['description']} -> #{_.keys(entry.json.codes)} != #{_.keys(matchedSystems)}") if !matches
      # trueMatchedSystems = CrosswalkManager.trueMatchedSystems[entry.id]
      # if (trueMatchedSystems? && _.keys(trueMatchedSystems).length > 0)
      #   matches = _.keys(entry.json.codes).length == _.keys(trueMatchedSystems).length
      #   fullMatch = fullMatch && matches
      #   Logger.info("TRUE MATCH: #{entry.json['description']} -> #{_.keys(entry.json.codes)} != #{_.keys(trueMatchedSystems)}") if !matches
  CrosswalkManager.clearValidateCodeSystemData()
  fullMatch

hQuery.CodedEntry::includesCodeFrom = (codeSet) ->
  allTrue = true
  oneTrue = false
  # tmpTrueMatchedSystems = {}
  matchedSystems = CrosswalkManager.matchedSystems[@id]
  for codedValue in @_type
    thisResult = codedValue.includedIn(codeSet)
    oneTrue = oneTrue || thisResult
    allTrue = allTrue && thisResult
    matchedSystems = {} unless matchedSystems?
    matchedSystems[codedValue.codeSystemName()] = true if (thisResult)
    # tmpTrueMatchedSystems[codedValue.codeSystemName()] = true if (thisResult)
  if (oneTrue && !allTrue)
    Logger.info("*** #{@json['description']}")
    for codedValue in @_type
      thisResult = codedValue.includedIn(codeSet)
      Logger.info("*** Logger is #{thisResult} for: #{Logger.toJson(codedValue)}")
  CrosswalkManager.matchedSystems[@id] = matchedSystems
  # CrosswalkManager.tmpTrueMatchedSystems[@id] = tmpTrueMatchedSystems
  oneTrue

instrumentTrueCrosswalk = (hqmfjs) ->
  # Wrap all of the data criteria functions generated from HQMF
  _.each(_.functions(hqmfjs), (method) ->
    if method != 'initializeSpecifics'
      hqmfjs[method] = _.wrap(hqmfjs[method], (func) ->

        args = Array.prototype.slice.call(arguments,1)

        isDataCriteria = method.match(/precondition_[0-9]+/)

        if isDataCriteria
          tmpCrosswalk = $.extend(true, {}, CrosswalkManager.matchedSystems)

        result = func.apply(this, args)

        if isDataCriteria && result.isFalse()
          CrosswalkManager.matchedSystems = tmpCrosswalk

        return result;
      );
  );
@instrumentTrueCrosswalk = instrumentTrueCrosswalk
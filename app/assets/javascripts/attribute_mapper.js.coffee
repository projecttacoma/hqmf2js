hQuery.Patient.prototype.extractEntries = (category, status) ->
  switch category
    when 'encounter'
      patient.encounters()
    when 'procedure'
      switch status
        when 'procedure_performed'
          patient.procedures()
        when 'procedure_adverse_event', 'procedure_intolerance'
          patient.allergies()
        when 'procedure_result'
          patient.procedureResults()
    when 'risk_category_assessment'
      patient.procedures()
    when 'communication'
      patient.procedures()
    when 'laboratory_test'
      patient.laboratoryTests()
    when 'physical_exam'
      patient.vitalSigns()
    when 'medication'
      switch status
        when 'dispensed', 'order', 'active', 'administered'
          patient.allMeds()
        when 'allergy', 'intolerance', 'adverse_event'
          patient.allergies()
    when 'diagnosis_condition_problem'
      switch status
        when 'diagnosis_active'
          patient.activeDiagnosis()
        when 'diagnosis_inactive'
          patient.inactiveDiagnosis()
        when 'diagnosis_resolved'
          patient.resolvedDiagnosis()
    when 'symptom'
      patient.allProblems()
    when 'individual_characteristic'
      patient.allProblems()
    when 'device'
      switch status
        when 'device_applied'
          patient.allDevices()
        when 'device_allergy'
          patient.allergies()
    when 'care_goal'
      patient.careGoals()
    when 'diagnostic_study'
      patient.procedures()
    when 'substance'
      patient.allergies()
    else
      []

hQuery.Patient.prototype.procedureResults = -> this.results().concat(this.vital_signs()).concat(this.procedures())
hQuery.Patient.prototype.laboratoryTests = -> this.results().concat(this.vitalSigns())
hQuery.Patient.prototype.allMedications = -> this.medications().concat(this.immunizations())
hQuery.Patient.prototype.allProblems = -> this.conditions().concat(this.socialHistories())
hQuery.Patient.prototype.allDevices = -> this.conditions().concat(this.procedures()).concat(this.careGoals()).concat(this.medicalEquipment())

hQuery.Patient.prototype.activeDiagnosis = ->
  entries = this.conditions().concat(this.socialhistories())
  (entry[0] for entry in entries when entry[0].json.status == 'active')

hQuery.Patient.prototype.inactiveDiagnosis = ->
  []
  #this.conditions().any_of({:status => 'inactive'}, {:status => nil}) + this.social_history().any_of({:status => 'inactive'}, {:status => nil})

hQuery.Patient.prototype.resolvedDiagnosis = ->
  []
  #this.conditions.any_of()({:status => 'resolved'}, {:status => nil}) + this.social_history().any_of({:status => 'resolved'}, {:status => nil})


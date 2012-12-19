@hqmf.CustomCalc = {}

class @hqmf.CustomCalc.PercentTTREntries extends hQuery.CodedEntryList

  constructor: (events) ->
    super()
    events = events.sort(dateSortAscending)
    @push(event) for event in events
    @minInr = 2.0
    @maxInr = 3.0
    # sort entries ascending
    # filter duplicates to those closest to 2.5
    # remove duplicate results on entries

  calculateDaysInRange: (firstInr, secondInr) ->

    if ((@belowRange(firstInr) and @belowRange(secondInr)) or (@aboveRange(firstInr) and @aboveRange(secondInr)))
      0
    else if (@inRange(firstInr) and @inRange(secondInr))
      @differenceInDays(firstInr,secondInr)
    else if (@outsideRange(firstInr) and @inRange(secondInr))
      @calculateCrossingRange(firstInr,secondInr)
    else if (@inRange(firstInr) and @outsideRange(secondInr))
      @calculateCrossingRange(secondInr, firstInr)
    else 
      @calculateSpanningRange(firstInr, secondInr)

  calculateCrossingRange: (outside,inside) ->
    outsideInr = @inrValue(outside)
    insideInr = @inrValue(inside)
    boundary = @maxInr
    boundary = @minInr if (@belowRange(outside))
    (Math.abs(boundary - insideInr)/Math.abs(insideInr-outsideInr))*@differenceInDays(outside,inside)

  calculateSpanningRange: (first,second) ->
    (1.0/Math.abs(@inrValue(first)-@inrValue(second)))*@differenceInDays(first,second)

  inRange: (entry) ->
    inr = @inrValue(entry)
    inr >= @minInr and inr <= @maxInr

  outsideRange: (entry) ->
    !@inRange(entry)

  belowRange: (entry) ->
    inr = @inrValue(entry)
    inr < @minInr

  aboveRange: (entry) ->
    inr = @inrValue(entry)
    inr > @maxInr
    
  differenceInDays: (first, second) ->
    getIVL(first).low.difference(getIVL(second).low, 'd')
    
  inrValue: (entry) ->
    entry.values()[0].scalar()
    
  totalNumberOfDays: () ->
    @differenceInDays(this[0],this[this.length-1])
    
  calculateTTR: () ->
    total = 0
    for left, i in this
      if (i < this.length-1)
        right = this[i+1]
        total += @calculateDaysInRange(left, right)
    total

  calculatePercentTTR: () ->
    @calculateTTR()/@totalNumberOfDays()*100
    

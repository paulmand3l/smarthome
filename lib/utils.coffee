moment = require 'moment'
suncalc = require 'suncalc'

# San Francisco
LATITUDE = 37.774929
LONGITUDE = -122.419416


interpolate = (num1, num2, percent) ->
  return (num2 - num1) * percent + num1

module.exports.getPercent = (num1, num2, num3) ->
  [min, middle, max] = [num1, num2, num3].sort()
  percent = (middle - min) / (max - min)
  return percent

module.exports.getSunTimes = ->
  timesDict = suncalc.getTimes new Date(), LATITUDE, LONGITUDE

  times = []

  for name, time of timesDict
    time = moment time
    time = moment hour: time.hour(), minute: time.minute()
    times.push name: name, time: time

  times.push name: 'bedtime', time: moment hour: 23
  times.push name: 'sleep', time: moment hour: 23, minute: 30

  times.sort (a, b) ->
    return a.time.valueOf() - b.time.valueOf()

  # for time in times
  #   console.log time.name, time.time.format('h:mm a'), time.time.valueOf()

  return times

module.exports.interpolateKeyFrames = (key1, key2, percentage=0) ->
  average = {}
  for lightID, values of key1
    if lightID not of key2
      throw new Error 'light mismatch', key1, key2
    else
      average[lightID] = {}
      for attr, val of values
        if attr not of key2[lightID]
          throw new Error 'Key mismatch', key1, key2
        else
          average[lightID][attr] = interpolate key1[lightID][attr], key2[lightID][attr], percentage
  return average

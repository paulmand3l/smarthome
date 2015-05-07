moment = require 'moment'

utils = require './utils'
getPercent = utils.getPercent
getSunTimes = utils.getSunTimes
interpolateKeyFrames = utils.interpolateKeyFrames

class SceneMaker
  constructor: (keyFrames) ->
    @keyFrames = keyFrames

  getTimes: ->
    getSunTimes().filter (time) =>
      time.name of @keyFrames

  getCurrentScene: ->
    @getScene moment()

  getScene: (time) ->
    [prev, next] = @getBoundingScenes time

    percentage = getPercent time.valueOf(), prev.time.valueOf(), next.time.valueOf()

    interpolateKeyFrames @keyFrames[prev.name], @keyFrames[next.name], percentage

  getBoundingScenes: (time) ->
    times = @getTimes()

    if time.isBefore(times[0].time)
      times[times.length-1].time.subtract 1, 'day'
      return [
        times[times.length-1]
        times[0]
      ]

    if time.isAfter(times[times.length-1].time)
      times[0].time.add 1, 'day'
      return [
        times[times.length-1]
        times[0]
      ]

    for timeData, i in times
      if time.isAfter timeData.time
        return [
          times[i]
          times[i+1]
        ]

module.exports = SceneMaker

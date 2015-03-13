_ = require 'lodash'

moment = require 'moment'
suncalc = require 'suncalc'
hue = require 'node-hue-api'

hostname = '10.0.1.2'
username = '3c9c3b207e640f289e3770160cb3ff'
api = new hue.HueApi hostname, username

# San Francisco
LATITUDE = 37.774929
LONGITUDE = -122.419416


# daytime - 5500k
# sunset - 3200K
# bedtime - 2000K

# 1 - Bed Overhead
# 2 - Table
# 3 - Windows Overhead
# 4 - Bedside
# 5 - Kitchen
# 6 - Couch
# 7 - Hue Lamp 5 //???
KEYFRAMES =
  goldenHour:
    1: { bri: 0, ct: 4000 }
    2: { bri: 0, ct: 4000 }
    3: { bri: 0, ct: 4000 }
  sunset:
    1: { bri: 255, ct: 2600 }
    2: { bri: 255, ct: 2600 }
    3: { bri: 255, ct: 2600 }
    6: { bri: 0, hue: 10000, sat: 50}
  night:
    1: { bri: 0, ct: 2000 }
    2: { bri: 200, ct: 2000 }
    3: { bri: 0, ct: 2000 }
    6: { bri: 255, hue: 8000, sat: 200}
  bedtime: # 11:00
    2: { bri: 200, ct: 2000 }
    4: { bri: 0, ct: 2000 }
    6: { bri: 255, hue: 7000, sat: 100}
  sleep: # 11:30
    2: { bri: 0, ct: 2000 }
    4: { bri: 150, ct: 2000 }
    6: { bri: 0, hue: 7000, sat: 200}


x1 = 2000
x2 = 6500

y1 = 500
y2 = 153

twoPointLine = (y2, y1, x2, x1) ->
  (x) -> (y2 - y1)/(x2 - x1) * (x - x1) + y1

# 6500K = 153 mirek
# 2000k = 500 mirek
KToMirek = twoPointLine y2, y1, x2, x1

for name, scene of KEYFRAMES
  for lightID, state of scene
    if state.ct?
      state.ct = KToMirek state.ct


getSunTimes = ->
  timesDict = suncalc.getTimes new Date(), LATITUDE, LONGITUDE

  times = []

  for name, time of timesDict
    if name of KEYFRAMES
      times.push name: name, time: moment time

  times.push name: 'bedtime', time: moment hour: 23
  times.push name: 'sleep', time: moment hour: 23, minute: 30

  times.sort (a, b) ->
    return a.time.valueOf() - b.time.valueOf()

  # for time in times
  #   console.log time.name, time.time.format('h:mm a'), time.time.valueOf()

  return times

getPercent = (num1, num2, num3) ->
  [min, middle, max] = [num1, num2, num3].sort()
  percent = (middle - min) / (max - min)
  console.log min
  console.log middle
  console.log max
  console.log percent
  return percent

interpolate = (num1, num2, percent) ->
  console.log num1, num2, percent
  return (num2 - num1) * percent + num1

interpolateKeyframes = (key1, key2, percentage) ->
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

setScene = (scene) ->
  for lightID, state of scene
    if state.bri? and state.bri isnt 0
      state.on = true
    else
      for attr, val of state
        delete state[attr]
      state.on = false
    console.log state
    api.setLightState lightID, state
      .done()

  console.log moment().format('h:mm a - '), JSON.stringify(scene, null, 2), '\n'

interpolateScene = (times, now) ->
  for _time, i in times
    break if now < times[i].time.valueOf()

  if i is 0
    console.log 'before the beginning'
    scene = KEYFRAMES[times[i].name]
  else if now > times[times.length-1].time.valueOf()
    console.log 'reached the end'
    scene = KEYFRAMES[times[times.length-1].name]
  else
    console.log 'in the middle'
    percent = getPercent now, times[i-1].time.valueOf(), times[i].time.valueOf()
    scene = interpolateKeyframes KEYFRAMES[times[i-1].name], KEYFRAMES[times[i].name], percent

  return scene

setCurrentFrame = ->
  now = Date.now()
  times = getSunTimes()

  return if now < times[0].time.valueOf()

  api.fullState().then (results) ->
    anythingOn = false
    for lightID, info of results.lights
      anythingOn ||= info.state.on

    if anythingOn
      scene = interpolateScene times, now
      setScene scene
    else
      console.log 'No lights on. Waiting for lights.'
  .done()

main = ->
  setCurrentFrame()
  setInterval ->
    setCurrentFrame()
  , 60 * 1000

main()

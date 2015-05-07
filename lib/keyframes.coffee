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
    4: { bri: 0, ct: 2000 }
    6: { bri: 0, hue: 10000, sat: 50}
  sunset:
    1: { bri: 255, ct: 4000 }
    2: { bri: 255, ct: 2400 }
    3: { bri: 255, ct: 4000 }
    4: { bri: 0, ct: 2000 }
    6: { bri: 0, hue: 10000, sat: 50}
  night:
    1: { bri: 0, ct: 2000 }
    2: { bri: 200, ct: 2000 }
    3: { bri: 0, ct: 2000 }
    4: { bri: 0, ct: 2000 }
    6: { bri: 255, hue: 8000, sat: 200}
  bedtime: # 11:00
    1: { bri: 0, ct: 2000 }
    2: { bri: 200, ct: 2000 }
    3: { bri: 0, ct: 2000 }
    4: { bri: 0, ct: 2000 }
    6: { bri: 255, hue: 7000, sat: 100}
  sleep: # 11:30
    1: { bri: 0, ct: 2000 }
    2: { bri: 0, ct: 2000 }
    3: { bri: 0, ct: 2000 }
    4: { bri: 150, ct: 2000 }
    6: { bri: 0, hue: 7000, sat: 200}

ENTRYWAY =
  nightEnd:
    8: { bri: 50 }
    9: { bri: 50 }
  dawn:
    8: { bri: 200 }
    9: { bri: 200 }
  sunrise:
    8: { bri: 255 }
    9: { bri: 255 }
  goldenHourEnd:
    8: { bri: 0 }
    9: { bri: 0 }
  goldenHour:
    8: { bri: 0 }
    9: { bri: 0 }
  sunset:
    8: { bri: 255 }
    9: { bri: 255 }
  night:
    8: { bri: 255 }
    9: { bri: 255 }
  bedtime:
    8: { bri: 150 }
    9: { bri: 150 }
  sleep:
    8: { bri: 50 }
    9: { bri: 50 }
  off:
    8: { bri: 0 }
    9: { bri: 0 }


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

for name, scene of ENTRYWAY
  for lightID, state of scene
    if state.ct?
      state.ct = KToMirek state.ct

module.exports.KEYFRAMES = KEYFRAMES
module.exports.ENTRYWAY = ENTRYWAY

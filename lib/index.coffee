smarthome = require './smarthome'

main = ->
  smarthome.listenForSpark()
  smarthome.setCurrentFrame()
  setInterval ->
    smarthome.setCurrentFrame()
  , 60 * 1000

main()

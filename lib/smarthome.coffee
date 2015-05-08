_ = require 'lodash'

moment = require 'moment'

SceneMaker = require './SceneMaker'

hue = require 'node-hue-api'
spark = require 'spark'

KEYFRAMES = require('./keyframes').KEYFRAMES
ENTRYWAY = require('./keyframes').ENTRYWAY


hostname = '10.0.1.2'
username = '3c9c3b207e640f289e3770160cb3ff'
api = new hue.HueApi hostname, username


LIGHTS_ON = false

smMain = new SceneMaker KEYFRAMES
smEntry = new SceneMaker ENTRYWAY

setScene = (scene) ->
  for lightID, state of scene
    if state.bri? and state.bri isnt 0
      state.on = true
    else
      for attr, val of state
        delete state[attr]
      state.on = false
    # console.log state
    api.setLightState lightID, state
      .done()

setCurrentFrame = ->
  currentScene = smMain.getCurrentScene()
  console.log currentScene
  setScene currentScene

turnOnEntryway = ->
  setScene smEntry.getCurrentScene()

listenForSpark = ->
  spark.login(accessToken: '3c01e062fa09f6d580ebcd78861a425246341bb0').then (data) ->
    # spark.onEvent 'movement', (data) ->
    #   LIGHTS_ON = true
    #   setCurrentFrame()
    #   console.log 'movement'

    # spark.onEvent 'exit', (data) ->
    #   LIGHTS_ON = false
    #   setScene KEYFRAMES.off
    #   console.log 'exit'

    spark.onEvent 'door.open', (data) ->
      turnOnEntryway()
      console.log 'door open', data

    spark.onEvent 'door.close', (data) ->
      setScene ENTRYWAY.off
      console.log 'door close', data

    setScene ENTRYWAY.off

  .done()



module.exports =
  setScene: setScene
  setCurrentFrame: setCurrentFrame
  listenForSpark: listenForSpark

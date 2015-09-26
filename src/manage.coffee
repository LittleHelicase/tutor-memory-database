
_ = require 'lodash'
moment = require 'moment'
uuid = require 'node-uuid'
utils = require './utils'
rndString = require 'randomstring'


module.exports = (root) ->

  storeTutor: (name, pw_hash) ->
    new Promise (resolve, reject) ->
      idx = _.findIndex root.DB.Tutors, {name: name}
      if idx == -1
        root.DB.Tutors.push {name: name, pw: pw_hash}
      else
        root.DB.Tutors[idx].pw = pw_hash
      resolve()

  storeExercise: (exercise) ->
    new Promise (resolve, reject) ->
      idx = _.findIndex root.DB.Exercises, {id: exercise.id}
      if idx == -1
        root.DB.Exercises.push exercise
      else
        root.DB.Exercises[idx] = exercise
      resolve()

  listUsers: ->
    new Promise (resolve, reject) ->
      resolve root.DB.Users

  listTutors: ->
    new Promise (resolve, reject) ->
      resolve _.map root.DB.Tutors, (t) -> t.name

  listGroups: ->
    new Promise (resolve, reject) ->
      resolve root.DB.Groups

  lockUnprocessedSolutions: ->
    new Promise (resolve) ->
      sol = _(root.DB.Solutions).chain()
        .reject (s) -> s.processed and not s.processingLock
        .sample()
        .value()
      sol.processingLock = true
      resolve sol

  processedSolution: (id, result, pdf) ->
    new Promise (resolve) ->
      idx = _.findIndex root.DB.Solutions, (s) -> s.id == id
      root.DB.Solutions[idx].processed = true
      root.DB.Solutions[idx].processingLock = false
      root.DB.Solutions[idx].pdf = pdf
      root.DB.Solutions[idx].slaveResult = result
      resolve()

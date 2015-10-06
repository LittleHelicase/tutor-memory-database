
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

  get: ->
    new Promise (resolve) ->
      # Memory queries don't fail...
      resolve root.DB.Exercises

  # Returns a specific exercise by id
  getById: (id) ->
    new Promise (resolve) ->
      res = _(root.DB.Exercises).chain()
          .filter id: id
          .first()
          .value()
      if res
        resolve res
      else
        reject()

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
    new Promise (resolve, reject) ->
      sol = _(root.DB.Solutions).chain()
        .reject (s) -> s.processed or s.processingLock
        .sample()
        .value()
      if !sol
        reject "No pending solutions to lock"
      idx = _.findIndex root.DB.Solutions, (s) -> s.id == sol.id
      if idx == -1
        reject "Solution has no ID and cannot be locked"
      root.DB.Solutions[idx].processingLock = true
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

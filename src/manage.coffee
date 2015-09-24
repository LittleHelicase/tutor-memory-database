
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

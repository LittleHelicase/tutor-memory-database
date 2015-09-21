
_ = require 'lodash'
moment = require 'moment'
uuid = require 'node-uuid'
utils = require './utils'


module.exports = (root) ->
  # Returns all exercises. Expired and active ones.
  get: ->
    new Promise (resolve) ->
      # Memory queries don't fail...
      resolve( _(root.DB.Exercises).chain()
          .filter (ex) -> moment().isAfter ex.activationDate
          .map (ex) ->
            exNew = _.clone ex
            delete exNew.tasks
            delete exNew.solutions
            exNew
          .value())


  # Returns a specific exercise by id
  getById: (id) ->
    new Promise (resolve) ->
      res = _(root.DB.Exercises).chain()
          .filter (ex) ->
            moment().isAfter ex.activationDate
          .filter id: id
          .map (ex) ->
            exNew = _.clone ex
            delete exNew.tasks
            delete exNew.solutions
            exNew
          .first()
          .value()
      if res
        resolve res
      else
        reject

  # Returns all exercises which can still be edited
  # expirationDate > now()
  getAllActive: ->
    new Promise (resolve) ->
      resolve( _(root.DB.Exercises).chain()
        .filter (ex) ->
          (moment().isAfter ex.activationDate) and
          moment().isBefore ex.dueDate
        .map (ex) ->
          exNew = _.clone ex
          delete exNew.tasks
          delete exNew.solutions
          exNew
        .value())

  # Exercise containing the tasks
  getDetailed: (id) ->
    new Promise (resolve) ->
      resolve( _(root.DB.Exercises).chain()
          .filter (ex) ->
            moment().isAfter ex.activationDate
          .filter id: id
          .map (ex) ->
            exNew = _.clone ex
            delete exNew.solutions
            exNew
          .first()
          .value())

  # Total points for current user
  getTotalPoints: (user_id, result) ->
    new Promise (resolve, reject) ->
      group = utils.groupForUser user_id, root.DB
      if group == -1
        reject "Could not find a group for user with ID #{user_id}"
        return
      groupID = group.id
      resolve( _(root.DB.Results).chain()
          .filter (res) ->
            res.group == groupID
          .map (res) -> res.points
          .reduce (a,b) -> a+b
          .value())

  getExerciseSolutions: (user_id, exercise_id) ->
    new Promise (resolve, reject) ->
      group = utils.groupForUser user_id, root.DB
      if group == -1
        reject "Could not find a group for user with ID #{user_id}"
        return
      groupID = group.id
      solutions = _.filter root.DB.Solutions ,(s) ->
        s.group == groupID and s.exercise == exercise_id
      if solutions.length > 1
        reject "Inconsistent DB, multiple solutions for group #{groupID} in exercise #{exercise_id}"
        return
      if solutions.length == 1
        resolve solutions[0]
      else
        resolve group: groupID, execise: exercise_id, solutions: []

  setExerciseSolution: (user_id, exercise_id, solutions) ->
    new Promise (resolve, reject) ->
      group = utils.groupForUser user_id, root.DB
      if group == -1
        reject "Could not find a group for user with ID #{user_id}"
        return
      s_idx = null
      solutions = _.filter root.DB.Solutions ,(s, idx) ->
        is_sol = s.group == groupID and s.exercise == exercise_id
        if is_sol then s_idx = idx
        return is_sol
      if solutions.length > 1
        reject "Inconsistent DB, multiple solutions for group #{groupID} in exercise #{exercise_id}"
        return
      if solutions.length == 1
        root.DB.Solutions[s_idx].solutions = solutions
        resolve root.DB.Solutions[s_idx]
      else
        root.DB.Solutions.push
          exercise: exercise_id
          group: groupID
          solutions: solutions
        resolve root.DB.Solutions[root.DB.Solutions.length - 1]

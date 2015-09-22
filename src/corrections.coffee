
_ = require 'lodash'
moment = require 'moment'
uuid = require 'node-uuid'
utils = require './utils'


module.exports = (root) ->
  hasResult = (solution) ->
    result = _.select root.DB.Results, (r) ->
      r.group == solution.group and r.exercise == solution.exercise
    return result.length == 1

  lockSolutionForTutor = (tutor, exercise_id, group_id) ->
    new Promise (resolve, reject) ->
      s_idx = -1
      solution = _.select root.DB.Solutions, (s, idx) ->
        searched = s.exercise == exercise_id and s.group == group_id
        if searched
          s_idx = idx
        return searched
      if solution.length == 0
        reject "Cannot lock non existing Solution (exercise: #{exercises_id}, group: #{group_id})"
      else if solution.length > 1
        reject "DB inconsistency, solution exists multiple times (exercise: #{exercises_id}, group: #{group_id})"
      else if solution[0].lock and solution[0].lock != tutor
        reject "Solution already locked for #{solution[0].lock}"
      else if hasResult solution[0]
        reject "Solution already has a result"
      else
        root.DB.Solutions[s_idx].lock = tutor
        resolve solution

  exerciseIDForNum = (number) ->
    _(root.DB.Exercises).chain()
      .select (e) -> e.number == exercise_num
      .pluck "id"
      .first()
      .value()

  API =
    # returns for every active exercise how many are worked on / not corrected
    # and already corrected
    # [
    #  {exercise: 1, solutions: 100, corrected: 50, locked: 10}
    # ]
    getStatus: ->
      exercises = _.filter root.DB.Exercises, (e) -> moment().isAfter e.activationDate
      status = _.map exercises, (e) ->
        Promise.all([
          API.getResultsForExercise(e.id),
          API.getSolutionsForExercise(e.id)
          # getLockedExercises(e.id)
        ]).then (values) ->
          exercise: e.id, solutions: values[1].length, corrected: values[0].length
      Promise.all status


    # get locked exercise for tutor

    # get the list of all results for an exercise
    getResultsForExercise: (exercise_id) ->
      new Promise (resolve, reject) ->
        ex_results = _.filter root.DB.Results, (r) -> exercise_id == r.exercise
        resolve ex_results

    getResultForExercise: (id) ->
      new Promise (resolve, reject) ->
        solutions = _.filter root.DB.Solutions, (s) -> s.id == id
        resolve solutions[0]

    setResultForExercise: (tutor, id, result) ->
      new Promise (resolve, reject) ->
        idx = _.findIndex root.DB.Solutions, (s) -> s.id == id
        if root.DB.Solutions[idx].lock != tutor
          reject "Only locked solutions can be updated"
        root.DB.Solutions[idx].result = result
        resolve()

    getSolutionsForExercise: (exercise_id) ->
      new Promise (resolve, reject) ->
        solutions = _.filter root.DB.Solutions, (s) -> s.exercise == exercise_id
        resolve solutions

    getLockedSolutionsForExercise: (exercise_id) ->
      new Promise (resolve, reject) ->
        solutions = _.filter root.DB.Solutions, (s) ->
          s.exercise == exercise_id and s.lock?
        resolve solutions

    lockNextSolutionForTutor: (tutor, exercise_id) ->
      solution = _(root.DB.Solutions).chain()
        .select (s) -> s.exercise == exercise_id
        .reject hasResult
        .sample()
        .value()

      if !solution?
        Promise.reject "No pending solutions to lock"
      else
        lockSolutionForTutor(tutor, solution.group, solution.exercise)

    getNumPending: (exercise_id) ->
      new Promise (resolve, reject) ->
        pending = _(root.DB.Solutions).chain()
          .select (s) -> s.exercise == exercise_id
          .reject hasResult
          .value()
        resolve pending.length


_ = require 'lodash'
moment = require 'moment'
uuid = require 'node-uuid'
utils = require './utils'


module.exports = (root) ->
  hasResult = (solution) ->
    "results" of solution

  isFinalized = (solution) ->
    "results" of solution and not solution.inProcess

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
        root.DB.Solutions[s_idx].inProcess = true
        resolve solution[0]

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
    getStatus: (name) ->
      exercises = _.filter root.DB.Exercises, (e) -> moment().isAfter e.activationDate
      status = _.map exercises, (e) ->
        Promise.all([
          API.getResultsForExercise(e.id),
          API.getSolutionsForExercise(e.id)
          API.getLockedSolutionsForExercise(e.id)
          API.getExerciseContingentForTutor(name, e.id)
        ]).then (values) ->
          exercise: e,
          solutions: values[1].length,
          corrected: values[0].length,
          locked: values[2].length
          should: values[3].should
          is: values[3].is

      Promise.all status

    getExerciseContingentForTutor: (name, exercise_id) ->
      new Promise (resolve) ->
        total_contingent = _.reduce root.DB.Tutors, ((acc, t) -> acc + t.contingent), 0
        tutor_contingent = (_.find root.DB.Tutors, (t) -> t.name == name).contingent
        ex_solutions = _.filter root.DB.Solutions, (s) -> s.exercise == exercise_id
        tutor_solutions = _.filter ex_solutions, (s) -> s.lock == name and s.inProcess == false

        perc_contingent = tutor_contingent / total_contingent
        resolve should: ex_solutions.length * perc_contingent, is: tutor_solutions.length

    # get locked exercise for tutor

    # get the list of all results for an exercise
    getResultsForExercise: (exercise_id) ->
      new Promise (resolve, reject) ->
        ex_results = _.select root.DB.Solutions, (s) -> exercise_id == s.exercise and isFinalized s
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
          return
        root.DB.Solutions[idx].result = result
        resolve()

    finishSolution: (tutor, id) ->
      new Promise (resolve, reject) ->
        idx = _.findIndex root.DB.Solutions, (s) -> s.id == id
        if root.DB.Solutions[idx].lock != tutor
          reject "Only locked solutions finished"
          return
        if !root.DB.Solutions[idx].results?
          reject "Cannot finish solution without a result"
          return
        root.DB.Solutions[idx].inProcess = false
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

    getFinishedSolutionsForTutor: (tutor) ->
      new Promise (resolve, reject) ->
        solutions = _.select root.DB.Solutions, (s) ->
          s.lock == tutor and not s.inProcess
        resolve solutions

    getUnfinishedSolutionsForTutor: (tutor) ->
      new Promise (resolve, reject) ->
        solutions = _.select root.DB.Solutions, (s) ->
          s.lock == tutor and s.inProcess
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
        lockSolutionForTutor(tutor, solution.exercise, solution.group)

    getNumPending: (exercise_id) ->
      new Promise (resolve, reject) ->
        pending = _(root.DB.Solutions).chain()
          .select (s) -> s.exercise == exercise_id
          .reject isFinalized
          .value()
        resolve pending.length

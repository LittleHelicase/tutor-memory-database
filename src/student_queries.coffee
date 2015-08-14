
_ = require 'lodash'
moment = require 'moment'

module.exports = (DB) ->
  # Returns all exercises. Expired and active ones.
  getExercises: (result) ->
    # Memory queries don't fail...
    result null, _.filter DB.Exercises, (ex) ->
      moment().isAfter ex.activationDate
  getExercise: (id, result) ->
    result null,
      _(DB.Exercises).chain()
        .filter (ex) ->
          moment().isAfter ex.activationDate
        .filter id: id
        .first()
        .value()

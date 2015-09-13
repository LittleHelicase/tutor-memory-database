
_ = require 'lodash'
moment = require 'moment'
uuid = require 'node-uuid'
utils = require './utils'


module.exports = (root) ->
  hasResult = (solution) ->
    result = _.select root.DB.Results, (r) ->
      r.group == solution.group and r.exercise == solution.exercise
    return result.length == 1

  # returns for every active exercise how many are worked on / not corrected
  # and already corrected
  getStatus: ->
    new Promise (resolve, reject) ->


  getNumPending: (exercise_id) ->
    new Promise (resolve, reject) ->
      pending = _(root.DB.Solutions).chain()
        .select (s) -> s.exercise == exercise_id
        .reject hasResult
        .value()
      resolve pending.length

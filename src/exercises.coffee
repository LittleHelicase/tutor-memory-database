
_ = require 'lodash'
moment = require 'moment'
uuid = require 'node-uuid'


module.exports = (root) ->
  # Returns all exercises. Expired and active ones.
  get: ->
    new Promise (resolve) ->
      # Memory queries don't fail...
      resolve( _(root.DB.Exercises).chain()
          .filter (ex) -> moment().isAfter ex.activationDate
          .map (ex) ->
            exNew = _.clone ex
            exNew.tasks = _.map ex.tasks, (t) -> t.id
            exNew
          .value())


  # Returns a specific exercise by id
  getById: (id) ->
    new Promise (resolve) ->
      resolve( _(root.DB.Exercises).chain()
          .filter (ex) ->
            moment().isAfter ex.activationDate
          .filter id: id
          .map (ex) ->
            exNew = _.clone ex
            exNew.tasks = _.map ex.tasks, (t) -> t.id
            exNew
          .first()
          .value())

  # Returns all exercises which can still be edited
  # expirationDate > now()
  getAllActive: ->
    new Promise (resolve) ->
      resolve( _(root.DB.Exercises).chain()
        .filter (ex) ->
          (moment().isAfter ex.activationDate) and
          moment().isBefore ex.dueDate
        .map (ex) -> (ex.tasks = _.map ex.tasks, (t) -> t.id); ex
        .value())

  # Exercise containing the tasks
  getDetailed: (id) ->
    new Promise (resolve) ->
      resolve( _(root.DB.Exercises).chain()
          .filter (ex) ->
            moment().isAfter ex.activationDate
          .filter id: id
          .first()
          .value())

  # Total points for current user
  getTotalPoints: (user_id, result) ->
    new Promise (resolve, reject) ->
      group = groupForUser user_id, root.DB
      if group == -1
        reject "Could not find a group for user with ID #{user_id}"
      groupID = group.id
      resolve( _(root.DB.Results).chain()
          .filter (res) ->
            res.group == groupID
          .map (res) -> res.points
          .reduce (a,b) -> a+b
          .value())

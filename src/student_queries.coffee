
_ = require 'lodash'
moment = require 'moment'
uuid = require 'node-uuid'


module.exports = (root) ->
  # Returns all exercises. Expired and active ones.
  getExercises: (result) ->
    # Memory queries don't fail...
    result null,
      _(root.DB.Exercises).chain()
        .filter (ex) -> moment().isAfter ex.activationDate
        .map (ex) ->
          exNew = _.clone ex
          exNew.tasks = _.map ex.tasks, (t) -> t.id
          exNew
        .value()


  # Returns a specific exercise by id
  getExerciseById: (id, result) ->
    result null,
      _(root.DB.Exercises).chain()
        .filter (ex) ->
          moment().isAfter ex.activationDate
        .filter id: id
        .map (ex) ->
          exNew = _.clone ex
          exNew.tasks = _.map ex.tasks, (t) -> t.id
          exNew
        .first()
        .value()

  # Returns all exercises which can still be edited
  # expirationDate > now()
  getAllActiveExercises: (result) ->
    result null,
      _(root.DB.Exercises).chain()
        .filter (ex) ->
          (moment().isAfter ex.activationDate) and
          moment().isBefore ex.dueDate
        .map (ex) -> (ex.tasks = _.map ex.tasks, (t) -> t.id); ex
        .value()

  # Exercise containing the tasks
  getDetailedExercise: (id, result) ->
    result null,
      _(root.DB.Exercises).chain()
        .filter (ex) ->
          moment().isAfter ex.activationDate
        .filter id: id
        .first()
        .value()

  # Total points for current user
  getTotalPoints: (user_id, result) ->
    group = groupForUser user_id, root.DB
    if group == -1
      result "Could not find a group for user with ID #{user_id}"
    groupID = group.id
    result null,
      _(root.DB.Results).chain()
        .filter (res) ->
          res.group == groupID
        .map (res) -> res.points
        .reduce (a,b) -> a+b
        .value()

  # set the solution for a group
  setSolution: (group_id, solution, result) ->


  userExists: (id, result) ->
    user = _.select root.DB.Users, (u) -> u.id == id
    if user.length == 1
      result null, true
    else if user.length == 0
      result null, false
    else
      result "DB inconsistency: The user #{id} exists multiple times"

  getUserPseudonym: (id, result) ->
    user = (_.select root.DB.Users, (u) -> u.id == id)[0]
    if user && user.pseudonym
      result null, user.pseudonym
    else if user
      result "User #{id} has no pseudonym"
    else
      result "User #{id} does not exists"

  setUserPseudonym: (id, pseudonym, result) ->
    pseudonymUser = _.select root.DB.Users, (u) -> u.pseudonym == pseudonym
    if pseudonymUser.length > 0
      result "Pseudonym #{pseudonym} already taken"
      return
    selection = {}
    user = (_.select root.DB.Users, (u,idx) ->
      if u.id == id
        selection.idx = idx
      return u.id == id
    )
    if user.length == 1
      root.DB.Users[selection.idx].pseudonym = pseudonym
      result null
    else if user.length == 0
      result "User #{id} does not exists"
    else
      result "DB inconsistency: The user #{id} exists multiple times"

  createUser: (id, matrikel, pseudonym, result) ->
    user = _.select root.DB.Users, (u) -> u.id == id
    if user.length != 0
      result "User with id #{id} already exists"
    else
      root.DB.Users.push id:id, matrikel:matrikel, pseudonym: pseudonym
      result null

  getPseudonymList: (result) ->
    pseudonyms = _.map root.DB.Users, "pseudonym"
    result null, _.compact pseudonyms

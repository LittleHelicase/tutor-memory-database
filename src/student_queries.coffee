
_ = require 'lodash'
moment = require 'moment'
uuid = require 'node-uuid'

groupForUser = (user, DB) ->
  group = _.filter DB.Groups, (g) ->
    _.includes g, user_id
  if group.length != 1
    return -1
  group[0]

module.exports = (DB) ->
  # Returns all exercises. Expired and active ones.
  getExercises: (result) ->
    # Memory queries don't fail...
    result null, _.filter DB.Exercises, (ex) ->
      moment().isAfter ex.activationDate

  # Returns a specific exercise by id
  getExerciseById: (id, result) ->
    result null,
      _(DB.Exercises).chain()
        .filter (ex) ->
          moment().isAfter ex.activationDate
        .filter id: id
        .first()
        .value()

  # Returns all exercises which can still be edited
  # expirationDate > now()
  getAllActiveExercises: (result) ->
    result null,
      _(DB.Exercises).chain()
        .filter (ex) ->
          moment().isAfter ex.activationDate and
          moment().isBefore ex.dueDate
        .filter id: id
        .first()
        .value()

  # Exercise containing the tasks
  getDetailedExercise: (id, result) ->
    result null, _.filter DB.Exercises, (ex) ->
      moment().isAfter ex.activationDate

  # get the Group of one user
  getGroup: (user_id, result) ->
    group = groupForUser user_id, DB
    if group == -1
      result "Could not find a group for user with ID #{user_id}"
    result null, group

  # Total points for current user
  getTotalPoints: (user_id, result) ->
    group = groupForUser user_id, DB
    if group == -1
      result "Could not find a group for user with ID #{user_id}"
    groupID = group.id
    result null,
      _(DB.Results).chain()
        .filter (res) ->
          res.group == groupID
        .map (res) -> res.points
        .reduce (a,b) -> a+b
        .value()

  # set the solution for a group
  setSolution: (group_id, solution, result) ->
    

  # removes a user from a group, creates a new (one man) group
  # and copies all the results to the new user
  leaveGroup: (user_id, result) ->
    # get current group
    group = groupForUser user_id, DB

    # create a clone group
    newGroup = _.cloneDeep group

    # remove user from group
    group.users = _.remove group.users, user_id

    # new group only contains the one user! and gets a new id
    newGroup.users = [user_id]
    newGroup.id = uuid.v4()

    # insert new Group
    DB.Groups.push newGroup

    # copy results from old group to new group
    groupResults = _(DB.Results).chain()
      .filter (res) -> res.group == group.id
      .map (res) -> res.group = newGroup.id; return res
      .value()

    # insert results for new group
    DB.Results.push groupResults

  # creates a group with specified users
  createGroup: (users_ids, result) ->
    newGroup =
      id: uuid.v4()
      users: users_ids

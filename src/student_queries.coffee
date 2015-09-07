
_ = require 'lodash'
moment = require 'moment'
uuid = require 'node-uuid'

groupForUser = (user, DB) ->
  group = _.filter DB.Groups, (g) ->
    _.includes g.users, user
  if group.length != 1
    return -1
  group[0]

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

  # get the Group of one user
  getGroupForUser: (user_id, result) ->
    group = groupForUser user_id, root.DB
    if group == -1
      result "Could not find a group for user with ID #{user_id}"
      return
    result null, group

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


  # removes a user from a group, creates a new (one man) group
  # and copies all the results to the new user
  leaveGroup: (user_id, result) ->
    # get current group
    group = groupForUser user_id, root.DB
    if group.users.length == 1
      result "It is not possible to leave a one-user group (uid=#{user_id},gid=#{group.id})."
      return

    # create a clone group
    newGroup = _.cloneDeep group

    # remove user from group
    _.remove group.users, (u) -> u == user_id

    # new group only contains the one user! and gets a new id
    newGroup.users = [user_id]
    newGroup.id = uuid.v4()

    # insert new Group
    root.DB.Groups.push newGroup

    # copy results from old group to new group
    groupResults = _(root.DB.Results).chain()
      .filter (res) -> res.group == group.id
      .map (res) -> res.group = newGroup.id; return res
      .value()

    # insert results for new group
    root.DB.Results.push groupResults
    result null, newGroup

  # creates a group with specified users
  createGroup: (users_ids, result) ->
    usersInGroup = _(users_ids).chain()
      .map _.partial groupForUser, _, root.DB
      .map (g,idx) -> if g==-1 then null else users_ids[idx]
      .compact()
      .value()
    if usersInGroup.length != 0
      result "The users #{users_ids} are already in a group"
      return

    newGroup =
      id: uuid.v4()
      users: users_ids
    root.DB.Groups.push newGroup
    result null, newGroup

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

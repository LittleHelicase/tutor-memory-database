

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
  # destructive removale of user. Make sure to insert him into another group afterwards
  leaveGroup = (user_id) ->
    group = groupForUser user_id, root.DB

    # remove user from group
    _.remove group.users, (u) -> u == user_id


  # return
  createGroup: (user_id, group_users, result) ->
    # make sure the user is not in two groups at the same time
    leaveGroup user_id

    # the creator immediatley joins the group
    pendingUsers = _.reject group_users, (id) -> id == user_id

    newGroup =
      id: uuid.v4()
      users: [user_id]
    if pendingUsers.length > 0
      newGroup.pendingUsers = pendingUsers
    root.DB.Groups.push newGroup
    result null, newGroup

  # returns a list of groups with pending invitations
  getPendingGroups: (user_id, result) ->
    pending = _.select root.DB.Groups, (g) ->
      g.pendingUsers and _.includes g.pendingUsers, user_id
    result null, pending

  joinGroup: (user_id, group_id, result) ->
    group = _.filter root.DB.Groups, id: group_id
    if group.length > 1
      result "Inconsistent groups. Multiple groups with ID: #{group_id}"
      return
    if group.length < 0
      result "Cannot join non existing group (ID: #{group_id})"
      return

    # return if the user is already in the group
    if _.includes group.users, user_id
      result()
      return
    # make sure the user is invited to the group
    if not group.pendingUsers or not _.includes group.pendingUsers, user_id
      result "User cannot join a group without invitation"
      return

    # make sure the user is not in two groups at the same time
    leaveGroup user_id
    group.pendingUsers = _.reject group.pendingUsers, user_id
    if group.pendingUsers.length == 0
      delete group.pendingUsers
    group.users.push user_id
    result()

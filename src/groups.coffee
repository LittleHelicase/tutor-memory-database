

_ = require 'lodash'
moment = require 'moment'
uuid = require 'node-uuid'
utils = require './utils'

module.exports = (root, config) ->
  # destructive removale of user. Make sure to insert him into another group afterwards
  leaveGroup = (user_id) ->
    group = utils.groupForUserId user_id, root.DB
    if group
      # remove user from group
      _.remove group.users, (u) -> u == user_id
    else
      config.log "User (#{user_id}) was in no group."


  # remove sensitive infomation in group
  desensetizeGroup = (group) ->
    dGroup = _.clone group
    dGroup.users = _.map dGroup.users, _.partial utils.pseudonymForUser, _, root.DB
    dGroup.pendingUsers = _.map dGroup.pendingUsers, _.partial utils.pseudonymForUser, _, root.DB
    return dGroup


  # return
  create: (user_id, group_users) ->
    new Promise (resolve, reject) ->
      # make sure the user is not in two groups at the same time
      leaveGroup user_id

      grp_userids = _.map group_users, (_.partial utils.userIDForPseudonym, _, root.DB)

      # the creator immediatley joins the group
      pendingUsers = _.reject grp_userids, (id) -> id == user_id

      newGroup =
        id: uuid.v4()
        users: [user_id]
      if pendingUsers.length > 0
        newGroup.pendingUsers = pendingUsers
      root.DB.Groups.push newGroup
      resolve desensetizeGroup newGroup

  # get the Group of one user
  getGroupForUser: (user_id) ->
    new Promise (resolve, reject) ->
      group = utils.groupForUserId user_id, root.DB
      if !group?
        reject "Could not find a group for user with Id #{user_id}"
        return
      resolve desensetizeGroup group

  # returns a list of groups with pending invitations
  pending: (user_id) ->
    new Promise (resolve) ->
      resolve _.map (_.select root.DB.Groups, (g) ->
        g.pendingUsers and _.includes g.pendingUsers, user_id), desensetizeGroup

  rejectInvitation: (user_id, group_id) ->
    new Promise (resolve, reject) ->
      group = _.find root.DB.Groups, id: group_id
      if !group?
        reject "User #{user_id} tried to leave non existing group #{group_id}"
        return
      if group.pendingUsers
        group.pendingUsers = _.reject group.pendingUsers, (id) -> user_id == id
      resolve()

  joinGroup: (user_id, group_id) ->
    new Promise (resolve, reject) ->
      group = _.find root.DB.Groups, id: group_id
      if !group?
        reject "User #{user_id} tried to join non existing group #{group_id}"
        return

      # return if the user is already in the group
      if _.includes group.users, user_id
        resolve desensetizeGroup group
        return
      # make sure the user is invited to the group
      if not group.pendingUsers or not _.includes group.pendingUsers, user_id
        reject "User cannot join a group without invitation"
        return

      # make sure the user is not in two groups at the same time
      leaveGroup user_id
      group.pendingUsers = _.reject group.pendingUsers, user_id
      if group.pendingUsers.length == 0
        delete group.pendingUsers
      group.users.push user_id
      resolve desensetizeGroup group

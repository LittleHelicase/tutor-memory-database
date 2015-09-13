
_ = require 'lodash'

module.exports =
  groupForUser: (user_pseudo, DB) ->
    group = _.filter DB.Groups, (g) ->
      _.includes g.users, user_pseudo
    if group.length != 1
      return -1
    group[0]

  pseudonymForUser: (id, DB) ->
    user = _.filter DB.Users, (u) -> u.id == id
    if user.length != 1
      return -1
    user[0].pseudonym

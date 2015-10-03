
_ = require 'lodash'

module.exports =
  userIDForPseudonym: (pseudonym, DB) ->
    _.result _.find(DB.Users, (u) -> u.pseudonym == pseudonym), "id"

  groupForUserId: (user_id, DB) ->
    _.find DB.Groups, (g) -> _.includes g.users, user_id

  pseudonymForUser: (id, DB) ->
    _.result _.find(DB.Users, (u) -> u.id == id), "pseudonym"


_ = require 'lodash'
moment = require 'moment'
uuid = require 'node-uuid'


module.exports = (root) ->
  exists: (pseudo) ->
    new Promise (resolve, reject) ->
      user = _.select root.DB.Users, (u) -> u.pseudonym == pseudo
      if user.length == 1
        resolve true
      else if user.length == 0
        resolve false
      else
        reject "DB inconsistency: The user #{pseudo} exists multiple times"

  getId: (pseudo) ->
    new Promise (resolve, reject) ->
      user = (_.select root.DB.Users, (u) -> u.pseudonym == pseudo)[0]
      if user && user.id
        resolve user.id
      else
        reject "User with pseudonym #{pseudo} does not exists"

  getPseudonym: (id) ->
    new Promise (resolve, reject) ->
      user = (_.select root.DB.Users, (u) -> u.id == id)[0]
      if user && user.pseudonym
        resolve user.pseudonym
      else
        reject "User with ID #{id} does not exists"

  setPseudonym: (pseudo, newPseudonym) ->
    new Promise (resolve, reject) ->
      pseudonymUser = _.select root.DB.Users, (u) -> u.pseudonym == newPseudonym
      if pseudonymUser.length > 0
        reject "Pseudonym #{newPseudonym} already taken"
        return
      selection = {}
      user = (_.select root.DB.Users, (u,idx) ->
        if u.pseudonym == pseudo
          selection.idx = idx
        return u.pseudonym == pseudo
      )
      if user.length == 1
        root.DB.Users[selection.idx].pseudonym = newPseudonym
        resolve()
      else if user.length == 0
        reject "User #{pseudo} does not exists"
      else
        reject "DB inconsistency: The user #{pseudo} exists multiple times"

  create: (id, matrikel, pseudonym) ->
    new Promise (resolve, reject) ->
      user = _.select root.DB.Users, (u) -> u.id == id
      if user.length != 0
        reject "User with id #{id} already exists"
      else
        root.DB.Users.push id:id, matrikel:matrikel, pseudonym: pseudonym
        resolve()

  getPseudonymList: ->
    new Promise (resolve) ->
      pseudonyms = _.map root.DB.Users, "pseudonym"
      resolve _.compact pseudonyms


_ = require 'lodash'
moment = require 'moment'
uuid = require 'node-uuid'


module.exports = (root) ->
  exists: (id) ->
    new Promise (resolve, reject) ->
      user = _.select root.DB.Users, (u) -> u.id == id
      if user.length == 1
        resolve true
      else if user.length == 0
        resolve false
      else
        reject "DB inconsistency: The user #{id} exists multiple times"

  getPseudonym: (id) ->
    new Promise (resolve, reject) ->
      user = (_.select root.DB.Users, (u) -> u.id == id)[0]
      if user && user.pseudonym
        resolve user.pseudonym
      else if user
        reject "User #{id} has no pseudonym"
      else
        reject "User #{id} does not exists"

  setPseudonym: (id, pseudonym) ->
    new Promise (resolve, reject) ->
      pseudonymUser = _.select root.DB.Users, (u) -> u.pseudonym == pseudonym
      if pseudonymUser.length > 0
        reject "Pseudonym #{pseudonym} already taken"
        return
      selection = {}
      user = (_.select root.DB.Users, (u,idx) ->
        if u.id == id
          selection.idx = idx
        return u.id == id
      )
      if user.length == 1
        root.DB.Users[selection.idx].pseudonym = pseudonym
        resolve()
      else if user.length == 0
        reject "User #{id} does not exists"
      else
        reject "DB inconsistency: The user #{id} exists multiple times"

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

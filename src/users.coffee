
_ = require 'lodash'
moment = require 'moment'
uuid = require 'node-uuid'
rndString = require 'randomstring'


module.exports = (root, config) ->
  config.lockTime = config.lockTime or 15
  clearPendingPseudonyms = ->
    root.DB.PseudonymList = _.reject root.DB.PseudonymList, (p) ->
      p.locked and moment().add(config.lockTime, "minutes").isAfter p.locked

  exists: (id) ->
    new Promise (resolve, reject) ->
      user = _.select root.DB.Users, (u) -> u.id == id
      if user.length == 1
        resolve true
      else if user.length == 0
        resolve false
      else
        reject "DB inconsistency: The user with ID #{id} exists multiple times"

  getPseudonym: (id) ->
    new Promise (resolve, reject) ->
      user = (_.select root.DB.Users, (u) -> u.id == id)[0]
      if user && user.pseudonym
        resolve user.pseudonym
      else
        reject "User with ID #{id} does not exists"

  setPseudonym: (id, newPseudonym) ->
    new Promise (resolve, reject) ->
      clearPendingPseudonyms()
      pseudonymUser = _.select root.DB.PseudonymList, (u) -> u.pseudonym == newPseudonym or u.user == id
      if pseudonymUser.length > 0
        reject "Pseudonym #{newPseudonym} already locked"
        return
      selection = {}
      user = (_.select root.DB.Users, (u,idx) ->
        if u.id == id
          selection.idx = idx
        return u.id == id
      )
      if user.length == 1
        root.DB.Users[selection.idx].pseudonym = newPseudonym
        pseudoIndex = _.findIndex root.DB.PseudonymList, (u) -> u.pseudonym == newPseudonym
        if pseudoIndex == -1
          root.DB.PseudonymList.push pseudonym: newPseudonym, user: id
        else
          delete root.DB.PseudonymList[pseudoIndex].locked
        resolve()
      else if user.length == 0
        reject "User #{id} does not exists"
      else
        reject "DB inconsistency: The user #{id} exists multiple times"

  create: (user) ->
    if not user.id or not user.name or not user.pseudonym or not user.matrikel
      return Promise.reject "User "
    new Promise (resolve, reject) ->
      userIdx = _.findIndex root.DB.Users, (u) -> u.id == id
      if userIdx != -1
        root.DB.Users[userIdx] = user
      else
        root.DB.Users.push user
        resolve()

  getPseudonymList: ->
    new Promise (resolve) ->
      pseudonyms = _.map root.DB.Users, "pseudonym"
      resolve _.compact pseudonyms

  lockRandomPseudonymFromList: (id, plist) ->
    new Promise (resolve, reject) ->
      clearPendingPseudonyms root
      pseudo = _(plist).chain()
        .reject (p) -> _.find root.DB.PseudonymList, (p2) -> p2.pseudonym == p
        .sample()
        .value()
      if !pseudo
        reject "all pseudonyms are locked"
      else
        root.DB.PseudonymList.push pseudonym: pseudo, user: id, locked: moment().toJSON()
        resolve pseudo

  getTutor: (name) ->
    new Promise (resolve, reject) ->
      tutor = _.select root.DB.Tutors, (t) -> t.name == name
      if tutor.length == 0
        reject "Tutor #{name} does not exist"
        return
      tutorClone = _.clone tutor[0]
      delete tutorClone.pw
      resolve tutorClone

  authTutor: (name, pw_hash) ->
    new Promise (resolve) ->
      tutor = _.select root.DB.Tutors, (t) -> t.name == name
      resolve tutor[0].pw == pw_hash

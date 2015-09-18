
fs = require 'fs'

root = {}

root.DB = require './dummy_db'

module.exports = (config) ->
  Set: (newDB) ->
    root.DB = newDB
  Restore: (file) ->
    root.DB = JSON.parse fs.readFileSync file, "utf8"
  Get: -> root.DB
  Backup: (toFile) ->
    fs.writeFileSync toFile, JSON.stringify root.DB

  Student: (require './student_queries')(root)
  Exercises: (require './exercises')(root)
  Users: (require './users')(root)
  Groups: (require './groups')(root)
  Corrections: (require './corrections')(root)
  Manage: (require './manage')(root)

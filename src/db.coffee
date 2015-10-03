
fs = require 'fs'

root = {}

root.DB = require './dummy_db'

module.exports = (config) ->
  if !config.log
    config.log = console.log.bind console
  Set: (newDB) ->
    root.DB = newDB
  Restore: (file) ->
    root.DB = JSON.parse fs.readFileSync file, "utf8"
  Get: -> root.DB
  Backup: (toFile) ->
    fs.writeFileSync toFile, JSON.stringify root.DB

  Student: (require './student_queries')(root, config)
  Exercises: (require './exercises')(root, config)
  Users: (require './users')(root, config)
  Groups: (require './groups')(root, config)
  Corrections: (require './corrections')(root, config)
  Manage: (require './manage')(root, config)

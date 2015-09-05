
fs = require 'fs'

root = {}

root.DB = require './dummy_db'

module.exports = (config) ->
  Set: (newDB) ->
    root.DB = newDB
  Restore: (DB, file) ->
    module.exports.Set JSON.parse file, fs.readFileSync
  Get: -> root.DB
  Backup: (toFile) ->
    fs.writeFileSync toFile, JSON.stringify root.DB

  Student: (require './student_queries')(root)

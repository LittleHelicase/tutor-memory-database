
DB = require './dummy_db'

module.exports = (config) ->
  Restore: (DB, file) ->
    DB = JSON.parse file, fs.readFileSync
  Backup: (toFile) ->
    fs.writeFileSync toFile, JSON.stringify DB
  Student: (require './student_queries')(DB)

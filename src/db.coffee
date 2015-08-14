
DB = require './dummy_db'

module.exports = (config) ->
  Student: (require './student_queries')(DB)

try
  v = require("../package.json").version
catch e
  v = undefined

module.exports =

  VERSION: v
  Logo: require './logo'

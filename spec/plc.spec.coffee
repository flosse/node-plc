should = require("chai").should()
pkg    = require '../package.json'
plc    = require "../src/plc"

describe "plc", ->

  it "contains the logo class", ->
    plc.Logo.should.be.a.function

  it "has a version property", ->
    plc.VERSION.should.be.a.string
    plc.VERSION.should.equal pkg.version

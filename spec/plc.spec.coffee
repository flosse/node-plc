global.buster = require "buster"
global.sinon  = require "sinon"
pkg           = require '../package.json'
buster.spec.expose()

describe "logo", ->

  before ->
    @plc = require "../lib/plc"

  it "contains the logo class", ->
    (expect typeof @plc.Logo).toEqual "function"

  it "has a version property", ->
    (expect typeof @plc.VERSION).toEqual "string"
    (expect @plc.VERSION).toEqual pkg.version

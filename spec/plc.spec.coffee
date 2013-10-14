global.buster = require "buster"
global.sinon  = require "sinon"
buster.spec.expose()

describe "logo", ->

  before ->
    @plc = require "../lib/plc"

  it "contains the logo class", ->
    (expect typeof @plc.Logo).toEqual "function"

  it "has a version property", ->
    (expect typeof @plc.VERSION).toEqual "string"

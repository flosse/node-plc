global.buster = require "buster"
global.sinon  = require "sinon"
buster.spec.expose()

describe "nodave", ->

  before ->
    @nodave = require("../build/Release/nodave").NoDave

  it "is a class", ->
    (expect typeof @nodave).toEqual "function"

  it "takes an IP-Address as constructor argument", ->
    (expect => new @nodave).toThrow()
    (expect => new @nodave "192.168.0.1").not.toThrow()
    (expect => new @nodave "x").toThrow()
    (expect => new @nodave "192.168.234.2011").toThrow()

  describe "class", ->

    before -> @d = new @nodave "192.168.0.1"

    it "has a connect method", ->
      (expect typeof @d.connect).toEqual "function"

    it "has a method to get markers", ->
      (expect typeof @d.getMarkers).toEqual "function"

    it "has a method to set markers", ->
      (expect typeof @d.setMarkers).toEqual "function"

    it "has a method to get inputs", ->
      (expect typeof @d.getInputs).toEqual "function"

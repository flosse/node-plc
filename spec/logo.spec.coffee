global.buster = require "buster"
global.sinon  = require "sinon"
buster.spec.expose()

describe "logo", ->

  before ->
    @Logo = require "../lib/logo"

  it "is a class", ->
    (expect typeof @Logo).toEqual "function"

  describe "constructor", ->

    it "takes an IP Address as first argument", ->
      (expect => new @Logo "192.168.0.1").not.toThrow()

    it "taks an option object as second argument", ->
      (expect => new @Logo "192.168.0.1", {}).not.toThrow()
      (expect (new @Logo "192.168.0.1", {inputs: 2}).inputs).toEqual 2
      (expect (new @Logo "192.168.0.1", {markers: 3}).markers).toEqual 3

    it "uses 8 inputs and 4 markers as default config", ->
      (expect (new @Logo "192.168.0.1").inputs).toEqual 8
      (expect (new @Logo "192.168.0.1").markers).toEqual 4

  describe "Logo class", ->

    before -> @logo = new @Logo "192.168.0.1"

    it "has a connect method", ->
      (expect typeof @logo.connect).toEqual "function"

    it "has a disconnect method", ->
      (expect typeof @logo.disconnect).toEqual "function"

    it "has a setMarker method", ->
      (expect typeof @logo.setMarker).toEqual "function"

    it "has a getMarker method", ->
      (expect typeof @logo.getMarker).toEqual "function"

    describe "getMarkers method", ->

      it "is a function", ->
        (expect typeof @logo.getMarkers).toEqual "function"

      it "returns null if the logo is disconnected", ->
        (expect @logo.getMarkers()).toBe null

    it "has a getInput method", ->
      (expect typeof @logo.getInput).toEqual "function"

    describe "getInput method", ->

      it "is a function", ->
        (expect typeof @logo.getInputs).toEqual "function"

      it "returns null if the logo is disconnected", ->
        (expect @logo.getInputs()).toBe null

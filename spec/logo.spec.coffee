should = require("chai").should()
Logo   = require "../src/logo"

describe "logo", ->

  it "is a class", ->
    Logo.should.be.a.function

  describe "constructor", ->

    it "takes an IP Address as first argument", ->
      (-> new Logo "192.168.0.1").should.not.throw()

    it "taks an option object as second argument", ->
      (-> new Logo "192.168.0.1", {}).should.not.throw()
      (new Logo "192.168.0.1", {inputs: 2}).inputs.should.equal 2
      (new Logo "192.168.0.1", {markers: 3}).markers.should.equal 3
      (new Logo "192.168.0.1", {timeout: 500}).timeout.should.equal 500

    it "uses 8 inputs and 8 markers as default config", ->
      (new Logo "192.168.0.1").inputs.should.equal 8
      (new Logo "192.168.0.1").markers.should.equal 8

  describe "Logo class", ->

    beforeEach -> @logo = new Logo "192.168.0.1"

    it "has a connect method", ->
     @logo.connect.should.be.a.function

    it "has a disconnect method", ->
      @logo.disconnect.should.be.a.function

    it "has a setMarker method", ->
      @logo.setMarker.should.be.a.function

    it "has a getMarker method", ->
      @logo.getMarker.should.be.a.function

    describe "getMarkers method", ->

      it "is a function", ->
        @logo.getMarkers.should.be.a.function

      it "returns an error if the logo is disconnected", ->
        @logo.getMarkers().should.be.an.Error

    it "has a getInput method", ->
      @logo.getInput.should.be.a.function

    describe "getInput method", ->

      it "is a function", ->
        @logo.getInputs.should.be.a.function

      it "returns an error if the logo is disconnected", ->
        @logo.getInputs().should.be.an.Error

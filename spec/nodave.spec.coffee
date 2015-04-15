should = require("chai").should()
nodave = (require "bindings")("addon").NoDave

describe "nodave", ->

  before ->

  it "is a class", ->
    nodave.should.be.a.function

  describe "class", ->

    beforeEach -> @d = new nodave "192.168.0.1"

    it "has a connect method", ->
      @d.connect.should.be.a.function

    it "has a method to get markers", ->
      @d.getMarkers.should.be.a.function

    it "has a method to set markers", ->
      @d.setMarkers.should.be.a.function

    it "has a method to get inputs", ->
      @d.getInputs.should.be.a.function

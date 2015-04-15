should = require("chai").should()
nodave = require("../build/Release/addon").NoDave

describe "nodave", ->

  before ->

  it "is a class", ->
    nodave.should.be.a.function

  it "takes an IP-Address as constructor argument", ->
    (-> new nodave).should.throw()
    (-> new nodave "192.168.0.1").should.not.throw()
    (-> new nodave "x").should.throw()
    (-> new nodave "192.168.234.2011").should.throw()

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

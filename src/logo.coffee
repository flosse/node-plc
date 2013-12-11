###
Copyright (c) 2012-2013, Maruks Kohlhase <mail@markus-kohlhase.de>
###

fs   = require "fs"
net  = require "net"
ev   = require "events"
dave = require "../build/Release/nodave"
bits = require "bits"

class Logo extends ev.EventEmitter

  constructor: (@ipAddress, opt={}) ->
    {@inputs, @markers, @timeout } = opt
    @_dave      = new dave.NoDave @ipAddress
    @inputs     ?= 8
    @markers    ?= 8
    @_simulate  ?= opt.simulate
    if @_simulate
      @_simMarkers = 0
      @_simInputs  = 0

  connected: false

  connect: ->
    if @_simulate
      @isConnected = true
      @emit "connect"
      return

    if not @_socket?
      @_socket = new net.Socket
      @_socket.setTimeout @timeout if @timeout

      @_socket.on "timeout", (ev) =>
        @emit "timeout", ev

      @_socket.on "error", (err) =>
        @isConnected = false
        @emit "error", err

      @_socket.on "close", (ev) =>
        @isConnected = false
        @emit "disconnect", ev

      @_socket.on "connect", =>
        try
          @_dave.connect @_socket._handle.fd, @timeout
          @isConnected = true
          @emit "connect"
        catch e
          @emit "error", e

    @_socket.connect 102, @ipAddress

  disconnect: ->
    @isConnected = false
    @_socket?.destroy()

  setMarker: (m) ->
    return null unless @isConnected
    if @_simulate
      @_simMarkers = bits.set @_simMarkers, m
    else
      @_dave.setMarkers bits.set @_dave.getMarkers(), m

  clearMarker: (m) ->
    return null unless @isConnected
    if @_simulate
      @_simMarkers = bits.clear @_simMarkers, m
    else
      @_dave.setMarkers bits.clear @_dave.getMarkers(), m

  getMarker: (m) ->
    return null unless @isConnected
    if @_simulate
      bits.test @_simMarkers, m
    else
      bits.test @_dave.getMarkers(), m

  getMarkers: ->
    return null unless @isConnected
    markers =
      if @_simulate then @_simMarkers
      else @_dave.getMarkers()
    for i in [0...@markers]
      bits.test markers, i

  setSimulatedInput: (i) ->
    return null unless @isConnected and @_simulate
    @_simInputs = bits.set @_simInputs, i

  clearSimulatedInput: (i) ->
    return null unless @isConnected and @_simulate
    @_simInputs = bits.clear @_simInputs, i

  getInput: (i) ->
    return null unless @isConnected
    if @_simulate
      bits.test @_simInputs, i
    else
      bits.test @_dave.getInputs(), i

  getInputs: ->
    return null unless @isConnected
    inputs =
      if @_simulate then @_simInputs
      else @_dave.getInputs()
    for i in [0...@inputs]
      bits.test inputs, i

module.exports = Logo

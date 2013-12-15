###
Copyright (c) 2012 - 2013, Markus Kohlhase <mail@markus-kohlhase.de>
###

fs   = require "fs"
net  = require "net"
ev   = require "events"
dave = require "../build/Release/nodave"
bits = require "bits"

NOT_CONNECTED = "plc is not connected"

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
        e = @_dave.connect @_socket._handle.fd, @timeout
        unless e instanceof Error
          @isConnected = true
          setImmediate => @emit "connect"
        else
          setImmediate => @emit "error", e
        return e

    @_socket.connect 102, @ipAddress

  disconnect: ->
    @isConnected = false
    @_socket?.destroy()

  setMarker: (m) ->
    return new Error NOT_CONNECTED unless @isConnected
    if @_simulate
      @_simMarkers = bits.set @_simMarkers, m
    else
      if (current = @_dave.getMarkers()) instanceof Error
        return current
      @_dave.setMarkers bits.set current, m

  clearMarker: (m) ->
    return new Error NOT_CONNECTED unless @isConnected
    if @_simulate
      @_simMarkers = bits.clear @_simMarkers, m
    else
      if (current = @_dave.getMarkers()) instanceof Error
        return current
      @_dave.setMarkers bits.clear current, m

  getMarker: (m) ->
    return new Error NOT_CONNECTED unless @isConnected
    if @_simulate
      bits.test @_simMarkers, m
    else
      if (current = @_dave.getMarkers()) instanceof Error
        return current
      bits.test current, m

  getMarkers: ->
    return new Error NOT_CONNECTED unless @isConnected
    markers =
      if @_simulate then @_simMarkers
      else @_dave.getMarkers()

    return markers if markers instanceof Error

    for i in [0...@markers]
      bits.test markers, i

  setSimulatedInput: (i) ->
    return new Error NOT_CONNECTED unless @isConnected and @_simulate
    @_simInputs = bits.set @_simInputs, i

  clearSimulatedInput: (i) ->
    return new Error NOT_CONNECTED unless @isConnected and @_simulate
    @_simInputs = bits.clear @_simInputs, i

  getInput: (i) ->
    return new Error NOT_CONNECTED unless @isConnected
    if @_simulate
      bits.test @_simInputs, i
    else
      if (current = @_dave.getInputs()) instanceof Error
        return current
      bits.test current, i

  getInputs: ->
    return new Error NOT_CONNECTED unless @isConnected
    inputs =
      if @_simulate then @_simInputs
      else @_dave.getInputs()
    return inputs if inputs instanceof Error
    for i in [0...@inputs]
      bits.test inputs, i

module.exports = Logo

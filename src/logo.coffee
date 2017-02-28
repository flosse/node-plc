###
Copyright (c) 2012 - 2017, Markus Kohlhase <mail@markus-kohlhase.de>
###

fs   = require "fs"
net  = require "net"
ev   = require "events"
dave = (require "bindings") 'addon'
bits = require "bits"

NOT_CONNECTED = "plc is not connected"

class Logo extends ev.EventEmitter

  constructor: (@ip, opt={}) ->
    unless typeof @ip is "string"
      throw new Error "invalid ip address"

    { @inputs, @markers, @timeout, @interval } = opt

    ### public properties ###

    @inputs       ?= 8
    @markers      ?= 8
    @interval     ?= 250
    @simulate     ?= opt.simulate
    @state         = {}

    ### private properties ###

    @_dave = new dave.NoDave @ip

    @_onInterval   ?= ->
    @_actionConfig  = opt.actions or {}
    @_stateConfig   = opt.states  or {}
    @_virtualState  = {}

    if @simulate
      @_simMarkers = 0
      @_simInputs  = 0

    process.nextTick @connect if opt.autoConnect is true

  connected: false

  connect: ->
    if @simulate
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

    @_socket.connect 102, @ip

  disconnect: ->
    @isConnected = false
    @_socket?.destroy()

  setMarker: (m) ->
    return new Error NOT_CONNECTED unless @isConnected
    if @simulate
      @_simMarkers = bits.set @_simMarkers, m
    else
      if (current = @_dave.getMarkers()) instanceof Error
        return current
      @_dave.setMarkers bits.set current, m

  clearMarker: (m) ->
    return new Error NOT_CONNECTED unless @isConnected
    if @simulate
      @_simMarkers = bits.clear @_simMarkers, m
    else
      if (current = @_dave.getMarkers()) instanceof Error
        return current
      @_dave.setMarkers bits.clear current, m

  getMarker: (m) ->
    return new Error NOT_CONNECTED unless @isConnected
    if @simulate
      bits.test @_simMarkers, m
    else
      if (current = @_dave.getMarkers()) instanceof Error
        return current
      bits.test current, m

  getMarkers: ->
    return new Error NOT_CONNECTED unless @isConnected
    markers =
      if @simulate then @_simMarkers
      else @_dave.getMarkers()

    return markers if markers instanceof Error

    for i in [0...@markers]
      bits.test markers, i

  setSimulatedInput: (i) ->
    return new Error NOT_CONNECTED unless @isConnected and @simulate
    @_simInputs = bits.set @_simInputs, i

  clearSimulatedInput: (i) ->
    return new Error NOT_CONNECTED unless @isConnected and @simulate
    @_simInputs = bits.clear @_simInputs, i

  setSimulatedState: (state, value) ->
    if @simulate and (x = @_stateConfig[state])?
      if x.input?
        if value is true
          @setSimulatedInput x.input
        else if value is false
          @clearSimulatedInput x.input
      else if x.marker?
        if value is true
          @setMarker x.marker
        else if value is false
          @clearMarker x.marker

  getInput: (i) ->
    return new Error NOT_CONNECTED unless @isConnected
    if @simulate
      bits.test @_simInputs, i
    else
      if (current = @_dave.getInputs()) instanceof Error
        return current
      bits.test current, i

  getInputs: ->
    return new Error NOT_CONNECTED unless @isConnected
    inputs =
      if @simulate then @_simInputs
      else @_dave.getInputs()
    return inputs if inputs instanceof Error
    for i in [0...@inputs]
      bits.test inputs, i

  _getState: (stateName, cfg, inputs, markers) ->
    s =
      if      cfg.input?   then inputs[cfg.input]
      else if cfg.marker?  then markers[cfg.marker]
      else if cfg.virtual?
        if (x=@_virtualState[stateName])? then x else cfg.default

    if cfg.inverse then not s else s

  getState: ->
    s = {}
    unless @isConnected
      console.warn "device with ip #{@ip} is offline"
      return s
    i = @getInputs()
    m = @getMarkers()
    if i instanceof Error or m instanceof Error
      console.warn "could not read state of #{@ip}"
      @disconnect()
      return s
    else
      for stateName, cfg of @_stateConfig
        s[stateName] = @_getState stateName, cfg, i, m
    s

  triggerAction: (action) ->
    unless typeof action is 'string'
      return console.warn "invalid action: #{action}"
    tasks = @_actionConfig[action]
    return unless tasks? and @isConnected
    for t in tasks
      if t.type in ['set', 'clear']
        if (typeof t.marker is 'number' or t.marker instanceof Array)
          switch t.type
            when 'clear' then @clearMarker t.marker
            when 'set'   then @setMarker t.marker
        if (typeof t.input is 'number' or t.input instanceof Array) and
           (t.simulate and @simulate)
          switch t.type
            when 'clear' then @clearSimulatedInput t.input
            when 'set'   then @setSimulatedInput t.input
      else if t.type is 'alias' and t.actions instanceof Array
        @triggerAction a for a in t.actions when a isnt action
    @_onStateInterval()

  setVirtualState: (state, val) ->
    if @_stateConfig[state]?.virtual?
      @_virtualState[state] = v

  startWatching: (interval) ->
    unless @_stateIntervalTimer?
      @_stateIntervalTimer =
        setInterval @_onStateInterval, interval or @interval
    unless @_connIntervalTimer?
      @_connIntervalTimer  = setInterval @_onConnectInterval, 8000

  stopWatching: ->
    clearInterval @_stateIntervalTimer
    clearInterval @_connIntervalTimer

  _onStateInterval: =>
    return unless @isConnected
    s      = @getState()
    change = false

    @_onInterval s

    for stateName, state of s
      if (x = @state?[stateName])?
        if x isnt state
          change = true
          break
      else
        change = true
        break

    @state = s
    @emit "state-change", s if change
    @emit "state", s

  _onConnectInterval: => @connect() unless @isConnected

module.exports = Logo

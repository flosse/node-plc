# node-plc

Node.js module to communicate with PLCs.
At the moment only the Siemens LOGO! PLC is supported.

[![Build Status](https://secure.travis-ci.org/flosse/node-plc.png)](http://travis-ci.org/flosse/node-plc)
[![Dependency Status](https://gemnasium.com/flosse/node-plc.png)](https://gemnasium.com/flosse/node-plc)
[![NPM version](https://badge.fury.io/js/plc.png)](http://badge.fury.io/js/plc)

## Usage

```shell
npm install --save plc
```

```javascript
var plc  = require("plc");
```

### Logo class

```javascript

var myLogo = new plc.Logo("192.168.0.1", {
  markers: 6,   // default is 8
  inputs: 4,    // default is 8
  timeout: 500  // socket timeout in milliseconds
});

myLogo.on("error", function(err){
  console.error(err.message);
});

myLogo.on("connect", function(){

  var result = myLogo.getInputs();
  if (result instanceof Error){
    return console.error(result.message);
  }
  console.log(result); // [true, false, false, true, false, true]

  result = myLogo.getMarkers();
  if (result instanceof Error){
    return console.error(result.message);
  }
  console.log(result); // [true, false, true, true]

  result = myLogo.setMarker(2);
  if (result instanceof Error){
    return console.error(result.message);
  }

  myLogo.disconnect();
});

myLogo.connect();
```

### Simulation

```javascript
var plc  = require("plc");

var myVirtualLogo = new plc.Logo("192.168.0.1", { simulate: true });

myLogo.on("connect", function(){

 /**
  * Since we cannot manipulate the inputs of a real PLCs
  * there is no "setInput" method. But within the simulation
  * mode we can use the special methods "setSimulatedInput"
  * and "clearSimulatedInput".
  */

  myVirtualLogo.setSimulatedInput(2);
  myLogo.getInput(2); // true
  myVirtualLogo.clearSimulatedInput(2);
  myLogo.getInput(2); // false

 /**
  * Markers can be used as usual.
  */

  myVirtualLogo.setMarker(1);
  myVirtualLogo.getMarker(1); // true
  myVirtualLogo.clearMarker(1);
  myVirtualLogo.getMarker(1); // false

});

myVirtualLogo.connect();
```

### Comfort features

The LOGO! can be configured with state and action schemata.
A states could be described like this:

```javascript
var myStates = {
  stateOne:   { input:  0 },
  stateTwo:   { marker: 2 },
  stateThree: { input:  2 }
};
```

An action consists of an array with defined desired states:

```javascript
var actions = {
  actionOne:
    [
      { type: 'clear', marker: 1 },
      { type: 'set',   marker: 3 }
    ],
  actionTwo:
    [ { type: 'set', marker: 2 } ],
  actionThree:
    [ { type: 'alias', actions: ['actionOne','actionTwo'] } ]
};
```

This is a full example:

```javascript
var config = {
  timeout:  500   // connection timeout
  interval: 250   // read state interval
  states: {
    x:   { input:  0 },
    y:   { input:  2 },
    foo: { marker: 0 },
    bar: { input:  1 }
  actions: {
    switchOne:
      [
        { type: 'set', marker: 3 }
      ],
    switchTwo:
      [
        { type: 'set',   marker:   1             },
        { type: 'alias', switches: ['switchOne'] }
      ]
    }
  }
};

var dev1 = new Device("192.168.0.201", config);

dev1.on("connect", function(){
  console.log("Device 1 connected");
});

dev1.on("timeout", function(){
  console.log("Device 1 connection timeout occoured");
});

dev1.on("disconnect", function(){
  console.log("Device 1 disconnected");
});

dev1.on("error", function(err){
  console.error("something went wrong: ", err.message);
});

dev.on('state-change', function(state){
  console.log(state);
  // { x: true, y: false, foo: true, bar: false }
});

dev1.connect();
dev1.startWatching();

// ...

dev1.stopWatching();
dev1.disconnect();
```

### API

#### Constructor

```javascript
new require("plc").Logo(ipAddress, options);
```

Following options are available

- `inputs` - number of used inputs
- `markers` - number of used markers
- `simulate` - simulation mode
- `timeout` - the socket timeout

#### Properties

- `ip`
- `isConnected`

#### Methods

- `connect()`
- `disconnect()`
- `setMarker(nr)`
- `clearMarker(nr)`
- `getMarker(nr)`
- `getMarkers()`
- `getInput(nr)`
- `getInputs()`
- `setSimulatedInput(nr)`
- `clearSimulatedInput(nr)`
- `getState()`
- `setSimulatedState(stateName, value)`
- `setVirtualState(stateName, value)`
- `triggerAction(action)`
- `startWatching`
- `stopWatching`

#### Events

- `error`
- `connect`
- `disconnect`
- `timeout`
- `state`
- `state-change`

## Test

```
npm test
```

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

#### Events

- `error`
- `connect`
- `disconnect`
- `timeout`

## Test

```
npm test
```

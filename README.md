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
  timeout: 500  // socket timeout
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

  result = myLogo.setMarker(2, true);
  if (result instanceof Error){
    return console.error(result.message);
  }

  myLogo.disconnect();
});

myLogo.connect();
```

## Test

```
npm test
```

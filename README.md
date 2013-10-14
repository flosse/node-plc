# node-plc

Node.js module to communicate with PLCs.
At the moment only the Siemens LOGO! PLC is supported.

## Usage

```shell
npm install plc
```

```javascript
var plc  = require("plc");

var myLogo = new plc.Logo("192.168.0.1");
myLogo.connect();
myLogo.getInputs();   // [true, false, false, false, false, true, false, false]
myLogo.getMarkers();  // [true, false, true, true]
myLogo.setMarker(2, true);
myLogo.disconnect();
```

## Test

```
npm test
```

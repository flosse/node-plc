/*******************************************************************************
 *    Copyright (c) 2012 - 2015, Markus Kohlhase <mail@markus-kohlhase.de>     *
 ******************************************************************************/

#include "node_nodave.h"

using namespace v8;

Persistent<Function> NoDave::constructor;

const int slot        = 0;
const int rack        = 1;
const int useProtocol = daveProtoISOTCP;
const int timeout     = 5000000;
const int port        = 102;

NoDave::NoDave(void) : ObjectWrap() {
}

NoDave::~NoDave() {
}

void NoDave::Init(Handle<Object> exports) {

  NanScope();

  // Prepare constructor template
  Local<FunctionTemplate> tpl = NanNew<FunctionTemplate>(New);
  tpl->SetClassName(NanNew("NoDave"));
  tpl->InstanceTemplate()->SetInternalFieldCount(1);

  // Prototype
  NODE_SET_PROTOTYPE_METHOD(tpl, "connect",     Connect);
  NODE_SET_PROTOTYPE_METHOD(tpl, "getMarkers",  GetMarkers);
  NODE_SET_PROTOTYPE_METHOD(tpl, "setMarkers",  SetMarkers);
  NODE_SET_PROTOTYPE_METHOD(tpl, "getInputs",   GetInputs);

  NanAssignPersistent(constructor, tpl->GetFunction());
  exports->Set(NanNew("NoDave"), tpl->GetFunction());
}

NAN_METHOD(NoDave::New) {
  NanScope();

  if (args.IsConstructCall()) {
    // Invoked as constructor: `new NoDave(...)`
    NoDave* obj = new NoDave();
    obj->Wrap(args.This());
    NanReturnValue(args.This());
  } else {

    // Invoked as plain function `NoDave(...)`, turn into construct call.

    const int argc = 1;
    Local<Value> argv[argc] = { args[0] };
    Local<Function> cons = NanNew<Function>(constructor);
    NanReturnValue(cons->NewInstance(argc, argv));
  }
}

NAN_METHOD(NoDave::Connect) {
  NanScope();
  int fd = -1;
  int to = timeout;
  daveInterface*  di;

  if (args.Length() < 1 || !args[0]->IsNumber())
    NanReturnValue(v8::Exception::TypeError(
      NanNew<String>("First argument must be a file descriptor")));

  fd = args[0]->ToInteger()->Value();

  NoDave* d   = ObjectWrap::Unwrap<NoDave>(args.Holder());
  d->fds.rfd  = fd;
  d->fds.wfd  = d->fds.rfd;

  if (d->fds.rfd>0) {

    di = daveNewInterface(d->fds, "IF1", 0, useProtocol, daveSpeed187k);

    if (args.Length() > 1 && args[1]->IsNumber())
      to = args[1]->ToInteger()->Value();

    daveSetTimeout(di, to);

    d->dc = daveNewConnection(di, 2, rack, slot);

   if (daveConnectPLC(d->dc))
      NanReturnValue(v8::Exception::Error(NanNew<String>("Could not connect")));
    NanReturnUndefined();
  }
  NanReturnValue(v8::Exception::Error(NanNew<String>("Could not connect")));
}

NAN_METHOD(NoDave::GetMarkers) {
  NanScope();
  NoDave* d = ObjectWrap::Unwrap<NoDave>(args.Holder());
  int buff[] = { 0 };
  if (daveReadBytes(d->dc, daveFlags, 0,0, 1, &buff))
      NanReturnValue(v8::Exception::Error(NanNew<String>("Could not read markers")));
  NanReturnValue(NanNew<Integer>(buff[0]));
}

NAN_METHOD(NoDave::SetMarkers) {
  NanScope();
  int val;

  if (args.Length() < 1 || !args[0]->IsNumber() )
    NanReturnValue(v8::Exception::Error(NanNew<String>("First argument must be an integer")));
  val = args[0]->ToInteger()->Value();
  int buff[] = { val };

  NoDave* d = ObjectWrap::Unwrap<NoDave>(args.Holder());
  if (daveWriteBytes(d->dc, daveFlags, 0, 0, 1, &buff))
    NanReturnValue(v8::Exception::Error(NanNew<String>("Could not set markers")));
  NanReturnUndefined();
}

NAN_METHOD(NoDave::GetInputs) {
  NanScope();
  int buff[] = { 0 };
  NoDave* d = ObjectWrap::Unwrap<NoDave>(args.Holder());
  if (daveReadBytes(d->dc, daveInputs, 0, 0, 1, &buff))
    NanReturnValue(v8::Exception::Error(NanNew<String>("Could not read inputs")));
  NanReturnValue(NanNew<Integer>(buff[0]));
}

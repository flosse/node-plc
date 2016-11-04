/*******************************************************************************
 *    Copyright (c) 2012 - 2016, Markus Kohlhase <mail@markus-kohlhase.de>     *
 ******************************************************************************/

#include "node_nodave.h"

using namespace v8;

Nan::Persistent<Function> NoDave::constructor;

const int slot        = 0;
const int rack        = 1;
const int useProtocol = daveProtoISOTCP;
const int timeout     = 5000000;
const int port        = 102;

NAN_MODULE_INIT(NoDave::Init) {

  // Prepare constructor template
  Local<FunctionTemplate> tpl = Nan::New<FunctionTemplate>(New);
  tpl->SetClassName(Nan::New("NoDave").ToLocalChecked());
  tpl->InstanceTemplate()->SetInternalFieldCount(1);

  // Prototype
  Nan::SetPrototypeMethod(tpl, "connect",     Connect);
  Nan::SetPrototypeMethod(tpl, "getMarkers",  GetMarkers);
  Nan::SetPrototypeMethod(tpl, "setMarkers",  SetMarkers);
  Nan::SetPrototypeMethod(tpl, "getInputs",   GetInputs);

  constructor.Reset(Nan::GetFunction(tpl).ToLocalChecked());
  Nan::Set(target, Nan::New("NoDave").ToLocalChecked(), Nan::GetFunction(tpl).ToLocalChecked());

}

NoDave::NoDave(void) : ObjectWrap() {
}

NoDave::~NoDave() {
}

NAN_METHOD(NoDave::New) {

  if (info.IsConstructCall()) {
    // Invoked as constructor: `new NoDave(...)`
    NoDave* obj = new NoDave();
    obj->Wrap(info.This());
    info.GetReturnValue().Set(info.This());
  } else {

    // Invoked as plain function `NoDave(...)`, turn into construct call.

    const int argc = 1;
    Local<Value> argv[argc] = { info[0] };
    Local<Function> cons = Nan::New<Function>(constructor);
    info.GetReturnValue().Set(cons->NewInstance(argc, argv));
  }
}

NAN_METHOD(NoDave::Connect) {
  int fd = -1;
  int to = timeout;
  daveInterface*  di;

  if (info.Length() < 1 || !info[0]->IsNumber())
    info.GetReturnValue().Set(Nan::TypeError("First argument must be a file descriptor"));

  fd = info[0]->ToInteger()->Value();

  NoDave* d  = ObjectWrap::Unwrap<NoDave>(info.Holder());
  d->fds.rfd = fd;
  d->fds.wfd = d->fds.rfd;

  if (d->fds.rfd>0) {

    di = daveNewInterface(d->fds, "IF1", 0, useProtocol, daveSpeed187k);

    if (info.Length() > 1 && info[1]->IsNumber())
      to = info[1]->ToInteger()->Value();

    daveSetTimeout(di, to);

    d->dc = daveNewConnection(di, 2, rack, slot);

    if (daveConnectPLC(d->dc))
      info.GetReturnValue().Set(Nan::Error("Could not connect"));
    return;
  }
  info.GetReturnValue().Set(Nan::Error("Could not connect"));
}

NAN_METHOD(NoDave::GetMarkers) {
  NoDave* d = ObjectWrap::Unwrap<NoDave>(info.Holder());
  int buff[] = { 0 };
  if (daveReadBytes(d->dc, daveFlags, 0,0, 2, &buff))
      info.GetReturnValue().Set(Nan::Error("Could not read markers"));
  info.GetReturnValue().Set(Nan::New<Integer>(buff[0]));
}

NAN_METHOD(NoDave::SetMarkers) {
  int val;
  if (info.Length() < 1 || !info[0]->IsNumber() )
    info.GetReturnValue().Set(Nan::Error("First argument must be an integer"));
  val = info[0]->ToInteger()->Value();
  int buff[] = { val };
  NoDave* d = ObjectWrap::Unwrap<NoDave>(info.Holder());
  if (daveWriteBytes(d->dc, daveFlags, 0, 0, 2, &buff))
    info.GetReturnValue().Set(Nan::Error("Could not set markers"));
  return;
}

NAN_METHOD(NoDave::GetInputs) {
  int buff[] = { 0 };
  NoDave* d = ObjectWrap::Unwrap<NoDave>(info.Holder());
  if (daveReadBytes(d->dc, daveInputs, 0, 0, 1, &buff))
    info.GetReturnValue().Set(Nan::Error("Could not read inputs"));
  info.GetReturnValue().Set(Nan::New<Integer>(buff[0]));
}

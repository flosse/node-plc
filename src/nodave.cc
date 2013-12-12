/*******************************************************************************
 *    Copyright (c) 2012 - 2013, Markus Kohlhase <mail@markus-kohlhase.de>     *
 ******************************************************************************/

#ifndef LINUX
  #define LINUX
#endif
#include "libnodave/nodavesimple.h"

#include <string.h>
#include <v8.h>
#include <node.h>
#include <node_object_wrap.h>

using namespace node;
using namespace v8;

const int slot        = 0;
const int rack        = 1;
const int useProtocol = daveProtoISOTCP;
const int timeout     = 5000000;
const int port        = 102;

class NoDave: public ObjectWrap
{
  private:
    char *ipAddress;
    daveConnection* dc;
    _daveOSserialType fds;

  public:
    static Persistent<FunctionTemplate> constructor;
    static void Init(Handle<Object> target);

  protected:
    NoDave(void);
    static Handle<Value> New        (const Arguments& args);
    static Handle<Value> connect    (const Arguments& args);
    static Handle<Value> getMarkers (const Arguments& args);
    static Handle<Value> setMarkers (const Arguments& args);
    static Handle<Value> getInputs  (const Arguments& args);
};

Persistent<FunctionTemplate> NoDave::constructor;

void NoDave::Init(Handle<Object> target)
{
  HandleScope scope;
  Local<FunctionTemplate> t = FunctionTemplate::New(New);
  Local<String> name = String::NewSymbol("NoDave");
  constructor = Persistent<FunctionTemplate>::New(t);
  constructor->InstanceTemplate()->SetInternalFieldCount(1);
  constructor->SetClassName(name);

  // bind the methods to the class
  NODE_SET_PROTOTYPE_METHOD(constructor, "connect",    connect    );
  NODE_SET_PROTOTYPE_METHOD(constructor, "getMarkers", getMarkers );
  NODE_SET_PROTOTYPE_METHOD(constructor, "setMarkers", setMarkers );
  NODE_SET_PROTOTYPE_METHOD(constructor, "getInputs",  getInputs  );

  // assign the template to 'NoDave' on the target
  target->Set(name, constructor->GetFunction());
}

NoDave::NoDave(void) :
  ObjectWrap(){}

Handle<Value> NoDave::New(const Arguments& args)
{
  HandleScope scope;

  if (!args.IsConstructCall())
    return ThrowException(Exception::TypeError(
        String::New("Use the new operator to create instances.")));

  if (args.Length() < 1 || !args[0]->IsString())
    return ThrowException(Exception::TypeError(
        String::New("First argument must be an IP-Adress")));

  NoDave* d = new NoDave();
  String::Utf8Value str(args[0]);
  if (str.length() < 7 || str.length() > 15)
    return ThrowException(Exception::TypeError(
        String::New("Invalid IP-Adress")));
  char *strPtr = (char *) malloc(str.length() + 1);
  strcpy(strPtr, *str);
  d->ipAddress = strPtr;
  d->Wrap(args.This());
  return args.This();
}

Handle<Value> NoDave::connect(const Arguments& args)
{
  HandleScope scope;
  int fd = -1;
  int to = timeout;
  daveInterface*  di;

  if (args.Length() < 1 || !args[0]->IsNumber())
    return scope.Close(Exception::TypeError(
        String::New("First argument must be a file descriptor")));

  fd = args[0]->ToInteger()->Value();

  NoDave* d   = ObjectWrap::Unwrap<NoDave>(args.This());
  d->fds.rfd  = fd;
  d->fds.wfd  = d->fds.rfd;

  if (d->fds.rfd>0) {

    di = daveNewInterface(d->fds,"IF1",0,useProtocol,daveSpeed187k);

    if (args.Length() > 1 && args[1]->IsNumber())
      to = args[1]->ToInteger()->Value();

    daveSetTimeout(di,to);

    d->dc = daveNewConnection(di,2,rack,slot);

    if (daveConnectPLC(d->dc))
      return scope.Close(Exception::Error(String::New("Could not connect")));
    return scope.Close(Undefined());
  }
  return scope.Close(Exception::Error(String::New("Could not connect")));
}

Handle<Value> NoDave::getMarkers(const Arguments& args)
{
  HandleScope scope;
  NoDave* d = ObjectWrap::Unwrap<NoDave>(args.This());
  int buff[] = { 0 };
  if (daveReadBytes(d->dc, daveFlags, 0,0, 1, &buff))
    return scope.Close(Exception::Error(
      String::New("Could not read markers")));
  return scope.Close(Integer::New(buff[0]));
}

Handle<Value> NoDave::setMarkers(const Arguments& args)
{
  HandleScope scope;
  int val;

  if (args.Length() < 1 || !args[0]->IsNumber() )
    return scope.Close(Exception::Error(
        String::New("First argument must be an integer")));

  val = args[0]->ToInteger()->Value();
  int buff[] = { val };

  NoDave* d = ObjectWrap::Unwrap<NoDave>(args.This());
  if (daveWriteBytes(d->dc, daveFlags, 0, 0, 1, &buff))
    return scope.Close(Exception::Error(
      String::New("Could not set markers")));
  return scope.Close(Undefined());
}

Handle<Value> NoDave::getInputs(const Arguments& args)
{
  HandleScope scope;
  int buff[] = { 0 };
  NoDave* d = ObjectWrap::Unwrap<NoDave>(args.This());
  if (daveReadBytes(d->dc, daveInputs, 0, 0, 1, &buff))
    return scope.Close(Exception::Error(
      String::New("Could not read inputs")));
  return scope.Close(Integer::New(buff[0]));
}

void RegisterModule(Handle<Object> target)
{
  NoDave::Init(target);
}

NODE_MODULE(nodave, RegisterModule);

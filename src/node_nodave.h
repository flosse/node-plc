#ifndef NODE_NODAVE_H
#define NODE_NODAVE_H

#ifndef LINUX
  #define LINUX
#endif

#include "libnodave/nodavesimple.h"

#include <nan.h>

class NoDave : public node::ObjectWrap {

  public:
    static void Init(v8::Handle<v8::Object> exports);

  protected:
    NanUtf8String *ipAddress;

  private:
    explicit NoDave(void);
    ~NoDave();

    static NAN_METHOD(New);
    static NAN_METHOD(Connect);
    static NAN_METHOD(GetMarkers);
    static NAN_METHOD(SetMarkers);
    static NAN_METHOD(GetInputs);

    static v8::Persistent<v8::Function> constructor;

    daveConnection* dc;
    _daveOSserialType fds;
};

#endif

#ifndef NODE_NODAVE_H
#define NODE_NODAVE_H

#ifndef LINUX
  #define LINUX
#endif

#include "libnodave/nodavesimple.h"

#include <nan.h>

class NoDave : public Nan::ObjectWrap {

  public:
    static NAN_MODULE_INIT(Init);

  private:
    explicit NoDave(void);
    ~NoDave();

    static NAN_METHOD(New);
    static NAN_METHOD(Connect);
    static NAN_METHOD(GetMarkers);
    static NAN_METHOD(SetMarkers);
    static NAN_METHOD(GetInputs);

    static Nan::Persistent<v8::Function> constructor;

    daveConnection* dc;
    _daveOSserialType fds;
};

#endif

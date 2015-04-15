#include <nan.h>
#include "node_nodave.h"

using namespace v8;

void InitAll(Handle<Object> exports) {
  NoDave::Init(exports);
}

NODE_MODULE(addon, InitAll)

#include <nan.h>
#include "node_nodave.h"

using namespace v8;

NAN_MODULE_INIT(InitAll) {
  NoDave::Init(target);
}

NODE_MODULE(addon, InitAll)

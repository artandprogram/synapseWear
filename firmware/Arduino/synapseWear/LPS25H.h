// LPS25H library for synapseWear

#include "Arduino.h"

#ifndef _LPS25H_H
#define _LPS25H_H

#define LPS25H_ADDRESS	0x5C

class LPS25H {

  public:

    bool begin();
    bool enable();
    bool disable();
    bool update();

    bool isConnected = false;
    bool isEnabled = false;
    float pressure = 0.0f;

};

#endif

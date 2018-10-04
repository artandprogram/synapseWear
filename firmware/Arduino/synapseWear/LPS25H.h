// LPS25H library for synapseWear

#include "Arduino.h"
#include "I2Cdev.h"

#ifndef _LPS25H_H
#define _LPS25H_H

#define LPS25H_ADDRESS	      0x5C
#define LPS25H_WHO_AM_I       0x0F
#define LPS25H_CTRL_REG1      0x20
#define LPS25H_POWERON1HZ     0x90
#define LPS25H_POWERON7HZ     0xA0
#define LPS25H_POWERDOWN      0x0

class LPS25H {

  public:

    bool begin();
    bool enable();
    bool disable();
    bool update();

    bool isConnected = false;
    bool isEnabled = false;
    float pressure = 0.0f;
    uint8_t buf[3] = {0};
};

#endif

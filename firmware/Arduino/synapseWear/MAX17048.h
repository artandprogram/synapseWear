// MAX17048/44 library for Arduino
//
// Created by Luca Dentella (http://www.lucadentella.it)

#include "Arduino.h"

#ifndef _MAX17048_H
#define _MAX17048_H

#define MAX17048_ADDRESS	0x36

#define VCELL_REGISTER		0x02
#define SOC_REGISTER		0x04
#define MODE_REGISTER		0x06
#define VERSION_REGISTER	0x08
#define CONFIG_REGISTER		0x0C
#define COMMAND_REGISTER	0xFE


class MAX17048 {

  public:

    float getVCell();
    float getSoC();
    int getVersion();
    byte getCompensateValue();
    byte getAlertThreshold();
    void setAlertThreshold(byte threshold);
    boolean inAlert();
    void clearAlert();
    void ReadDataBytes(byte data[4]);

    void reset();
    void quickStart();
    bool begin();
    bool enable();
    bool disable();
    bool update();
    uint8_t * getDataBuffer();

    uint8_t buf[4];
    float voltage = 0.0f;
    float stateOfCharge = 0.0f;

    bool isConnected = false;
    bool isEnabled = false;

  private:

    void readConfigRegister(byte &MSB, byte &LSB);
    void readRegister(byte startAddress, byte &MSB, byte &LSB);
    void writeRegister(byte address, byte MSB, byte LSB);

};

#endif

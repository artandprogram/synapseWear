/*
  Created by Alexander Reeder, 2018 Feb 20

  Original code and concept from Adafruit 
  https://learn.adafruit.com/adafruit-microphone-amplifier-breakout/measuring-sound-levels
*/

#ifndef _SPH1642HT5H_H
#define _SPH1642HT5H_H

#include "Arduino.h"

class SPH1642HT5H {

  public:

    SPH1642HT5H(uint8_t PIN_VDD, uint8_t PIN_AUD);
    bool begin();
    bool update();
    bool enable();
    bool disable();
    uint16_t getSoundLevel();

    uint32_t sampleWindowMillis;
    const uint8_t sampleWindow = 49;
    uint16_t sample;
    uint16_t signalMax = 0;
    uint16_t signalMin = 1024;
    uint16_t peakToPeak = 0;
    bool isConnected = false;
    bool isEnabled = false;
    uint8_t _PIN_VDD;
    uint8_t _PIN_AUD;

  private:

};

#endif

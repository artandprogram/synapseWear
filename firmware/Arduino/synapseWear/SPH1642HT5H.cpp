/*
  Created by Alexander Reeder, 2018 Feb 20

  Original code and concept from Adafruit 
  https://learn.adafruit.com/adafruit-microphone-amplifier-breakout/measuring-sound-levels
*/

#include "SPH1642HT5H.h"

SPH1642HT5H::SPH1642HT5H(uint8_t PIN_VDD, uint8_t PIN_AUD)
{
  _PIN_VDD = PIN_VDD;
  pinMode(_PIN_VDD, OUTPUT);
  digitalWrite(_PIN_VDD, LOW);

  _PIN_AUD = PIN_AUD;
  pinMode(_PIN_AUD, INPUT);
}

bool SPH1642HT5H::begin()
{
  isConnected = true;

  disable();

  return true;
}

bool SPH1642HT5H::enable()
{
  if (isEnabled)
    return true;

  sampleWindowMillis = millis() + sampleWindow;
  peakToPeak = 0;
  digitalWrite(_PIN_VDD, HIGH);
  isEnabled = true;
}

bool SPH1642HT5H::disable()
{
  peakToPeak = 65535;
  digitalWrite(_PIN_VDD, LOW);
  isEnabled = false;
}

bool SPH1642HT5H::update()
{
  if (!isEnabled)
    return false;

  if (millis() < sampleWindowMillis) {
    sample = analogRead(_PIN_AUD);
    if (sample < 1024)  // toss out spurious readings
    {
      if (sample > signalMax)
      {
        signalMax = sample;  // save just the max levels
      }
      else if (sample < signalMin)
      {
        signalMin = sample;  // save just the min levels
      }
    }
  }
  else {
    peakToPeak = signalMax - signalMin;
    signalMax = 0;
    signalMin = 1024;
    sampleWindowMillis = millis() + sampleWindow;
  }
}

uint16_t SPH1642HT5H::getSoundLevel()
{
  if (peakToPeak > 1024) {
    return 65535;
  }

  return peakToPeak;
}


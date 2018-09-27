/*
  synapseWear
  For license and other information refer to https://github.com/artandprogram/synapseWear
*/
#include <SimbleeBLE.h>
#include <Wire.h>
#include "synapseWear.h"

#define SERIAL_DEBUG
#define PING_I2C

SYNAPSEWEAR synapseWear;
uint32_t pin_battchg = 7;
uint32_t lastPlugTime = 0;
uint32_t plugCount = 0;

void setup()
{
  pinMode(PIN_BATTCHG, INPUT_PULLUP);

  Serial.begin(9600);
  Wire.begin();
  synapseWear.begin();

  if (digitalRead(PIN_BATTCHG) == LOW) {
    attachPinInterrupt(PIN_BATTCHG, endCharging, HIGH);
    synapseWear.beginCharging();
  }
  else {
    attachPinInterrupt(PIN_BATTCHG, beginCharging, LOW);
  }
}

void loop()
{
  synapseWear.update();
}

void SimbleeBLE_onConnect()
{
  Serial.println("SimbleeBLE_onConnect()");
  synapseWear.bleOnConnect();
}

void SimbleeBLE_onDisconnect()
{
  Serial.println("SimbleeBLE_onDisconnect()");
  synapseWear.bleOnDisconnect();
}

void SimbleeBLE_onReceive(char *data, int len)
{
  Serial.println("SimbleeBLE_onReceive()");
  synapseWear.bleOnReceive(data, len);
}

int beginCharging(uint32_t pin)
{
  if ((millis() - lastPlugTime < 100)) {
    plugCount++;
    if (plugCount == 3) {
      Serial.println("beginCharging: no battery connected, disabling interrupts");
      detachPinInterrupt(PIN_BATTCHG);
      return 0;
    }
  }
  lastPlugTime = millis();
  synapseWear.beginCharging();
  detachPinInterrupt(PIN_BATTCHG);
  attachPinInterrupt(PIN_BATTCHG, endCharging, HIGH);
  return 0;
}

int endCharging(uint32_t pin)
{
  lastPlugTime = millis();
  synapseWear.endCharging();
  detachPinInterrupt(PIN_BATTCHG);
  attachPinInterrupt(PIN_BATTCHG, beginCharging, LOW);
  return 0;
}


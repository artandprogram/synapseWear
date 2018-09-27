/*****************************************************************************
  BM1383AGLV.cpp

  Copyright (c) 2017 ROHM Co.,Ltd.

  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in
  all copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
  THE SOFTWARE.
******************************************************************************/
#include <avr/pgmspace.h>
#include <Arduino.h>
#include <Wire.h>
#include "BM1383AGLV.h"

BM1383AGLV::BM1383AGLV(void)
{

}

bool BM1383AGLV::begin(void)
{
  byte rc;
  unsigned char reg;

  rc = read(BM1383AGLV_ID, &reg, sizeof(reg));
  if (rc != 0) {
    Serial.println(F("Can't access BM1383AGLV"));
    return false;
    //return (rc);
  }
  //Serial.print(F("BM1383AGLV ID Register Value = 0x"));
  //Serial.println(reg, HEX);

  if (reg != BM1383AGLV_ID_VAL) {
    Serial.println(F("Can't find BM1383AGLV"));
    return false;
    //return (rc);
  }
  isConnected = true;

  disable();

  isEnabled = false;

  return true;
}

byte BM1383AGLV::get_rawval(unsigned char *data)
{
  byte rc;

  rc = read(BM1383AGLV_PRESSURE_MSB, data, GET_BYTE_PRESS_TEMP);
  if (rc != 0) {
    Serial.println(F("Can't get BM1383AGLV PRESS and TEMP value"));
  }

  return (rc);
}

bool BM1383AGLV::enable()
{
  if (isEnabled)
    return true;

  byte rc;
  unsigned char reg;

  reg = BM1383AGLV_RESET_VAL;
  rc = write(BM1383AGLV_RESET, &reg, sizeof(reg));

  reg = BM1383AGLV_MODE_CONTROL_VAL;
  rc = write(BM1383AGLV_MODE_CONTROL, &reg, sizeof(reg));

  //delay(WAIT_TMT_MAX);

  isEnabled = true;
}

bool BM1383AGLV::disable()
{
  byte rc;
  unsigned char reg;

  reg = BM1383AGLV_POWER_DOWN_VAL;
  rc = write(BM1383AGLV_POWER_DOWN, &reg, sizeof(reg));

  pressure = 65535.0f;
  isEnabled = false;
}

bool BM1383AGLV::update()
{
  if (!isEnabled)
    return false;

  byte rc;
  unsigned char val[GET_BYTE_PRESS_TEMP];
  unsigned long rawpress;
  short rawtemp;

  rc = get_rawval(val);
  if (rc != 0) {
    return false;
  }

  rawpress = (((unsigned long)val[0] << 16) | ((unsigned long)val[1] << 8) | (val[2] & 0xFC)) >> 2;

  if (rawpress == 0) {
    return false;
  }

  pressure = (float)rawpress / HPA_PER_COUNT;

  /*
    rawtemp = ((short)val[3] << 8) | val[4];

    if (rawtemp == 0) {
      return false;
    }

    celsius = (float)rawtemp / DEGREES_CELSIUS_PER_COUNT;
  */

  return true;
}

byte BM1383AGLV::get_val(float *press, float *temp)
{
  byte rc;
  unsigned char val[GET_BYTE_PRESS_TEMP];
  unsigned long rawpress;
  short rawtemp;

  rc = get_rawval(val);
  if (rc != 0) {
    return (rc);
  }

  rawpress = (((unsigned long)val[0] << 16) | ((unsigned long)val[1] << 8) | (val[2] & 0xFC)) >> 2;

  if (rawpress == 0) {
    return (-1);
  }

  *press = (float)rawpress / HPA_PER_COUNT;

  /*
    rawtemp = ((short)val[3] << 8) | val[4];

    if (rawtemp == 0) {
    return (-1);
    }

    temp = (float)rawtemp / DEGREES_CELSIUS_PER_COUNT;
  */

  return (rc);
}

byte BM1383AGLV::write(unsigned char memory_address, unsigned char *data, unsigned char size)
{
  byte rc;

  Wire.beginTransmission(BM1383AGLV_DEVICE_ADDRESS);
  Wire.write(memory_address);
  Wire.write(data, size);
  rc = Wire.endTransmission();
  return (rc);
}

byte BM1383AGLV::read(unsigned char memory_address, unsigned char *data, int size)
{
  byte rc;
  unsigned char cnt;

  Wire.beginTransmission(BM1383AGLV_DEVICE_ADDRESS);
  Wire.write(memory_address);
  rc = Wire.endTransmission(false);
  if (rc != 0) {
    return (rc);
  }

  Wire.requestFrom(BM1383AGLV_DEVICE_ADDRESS, size, true);
  cnt = 0;
  while (Wire.available()) {
    data[cnt] = Wire.read();
    cnt++;
  }

  return (rc);
}

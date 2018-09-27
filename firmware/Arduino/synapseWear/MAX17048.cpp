// MAX17048/49 library for Arduino
//
// Created by Luca Dentella (http://www.lucadentella.it)
// Modified by Ali Kianzadeh

#include "MAX17048.h"
#include "Wire.h"

bool MAX17048::begin()
{
  isConnected = true;

  reset();
  delay(2);

  disable();

  return true;
}

float MAX17048::getVCell() {

  byte MSB = 0;
  byte LSB = 0;

  readRegister(VCELL_REGISTER, MSB, LSB);
  buf[0] = MSB;
  buf[1] = LSB;
  int value = (MSB << 4) | (LSB >> 4);
  return map(value, 0x000, 0xFFF, 0, 50000) / 10000.0;
  //return value * 0.00125;
}

float MAX17048::getSoC() {

  byte MSB = 0;
  byte LSB = 0;

  readRegister(SOC_REGISTER, MSB, LSB);
  buf[2] = MSB;
  buf[3] = LSB;
  float decimal = LSB / 256.0;
  return MSB + decimal;
}

void MAX17048::ReadDataBytes(byte data[4]) {

  byte MSB = 0;
  byte LSB = 0;

  readRegister(VCELL_REGISTER, MSB, LSB);
  data[0] = MSB;
  data[1] = LSB;

  readRegister(SOC_REGISTER, MSB, LSB);
  data[2] = MSB;
  data[3] = LSB;
}

int MAX17048::getVersion() {

  byte MSB = 0;
  byte LSB = 0;

  readRegister(VERSION_REGISTER, MSB, LSB);
  return (MSB << 8) | LSB;
}

byte MAX17048::getCompensateValue() {

  byte MSB = 0;
  byte LSB = 0;

  readConfigRegister(MSB, LSB);
  return MSB;
}

byte MAX17048::getAlertThreshold() {

  byte MSB = 0;
  byte LSB = 0;

  readConfigRegister(MSB, LSB);
  return 32 - (LSB & 0x1F);
}

void MAX17048::setAlertThreshold(byte threshold) {

  byte MSB = 0;
  byte LSB = 0;

  readConfigRegister(MSB, LSB);
  if (threshold > 32) threshold = 32;
  threshold = 32 - threshold;

  writeRegister(CONFIG_REGISTER, MSB, (LSB & 0xE0) | threshold);
}

boolean MAX17048::inAlert() {

  byte MSB = 0;
  byte LSB = 0;

  readConfigRegister(MSB, LSB);
  return LSB & 0x20;
}

void MAX17048::clearAlert() {

  byte MSB = 0;
  byte LSB = 0;

  readConfigRegister(MSB, LSB);
}

void MAX17048::reset() {
  writeRegister(COMMAND_REGISTER, 0x00, 0x54);
}

void MAX17048::quickStart() {
  writeRegister(MODE_REGISTER, 0x40, 0x00);
}

void MAX17048::readConfigRegister(byte &MSB, byte &LSB) {

  readRegister(CONFIG_REGISTER, MSB, LSB);
}

void MAX17048::readRegister(byte startAddress, byte &MSB, byte &LSB) {

  Wire.beginTransmission(MAX17048_ADDRESS);
  Wire.write(startAddress);
  Wire.endTransmission();

  Wire.requestFrom(MAX17048_ADDRESS, 2);
  MSB = Wire.read();
  LSB = Wire.read();
}

void MAX17048::writeRegister(byte address, byte MSB, byte LSB) {

  Wire.beginTransmission(MAX17048_ADDRESS);
  Wire.write(address);
  Wire.write(MSB);
  Wire.write(LSB);
  Wire.endTransmission();
}

bool MAX17048::enable()
{

  if (isEnabled)
    return true;

  writeRegister(MODE_REGISTER, 0x20, 0x00);

  isEnabled = true;
}

bool MAX17048::disable()
{
  writeRegister(MODE_REGISTER, 0x20, 0x01);
  for (int i = 0; i < 4; i++) {
    buf[i] = 0xff;
  }

  isEnabled = false;
}

bool MAX17048::update()
{
  if (!isEnabled)
    return false;

  voltage = getVCell();
  stateOfCharge = getSoC();
}

uint8_t * MAX17048::getDataBuffer()
{
  return buf;
}

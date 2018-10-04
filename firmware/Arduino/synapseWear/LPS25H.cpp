// LPS25H library for synapseWear

#include "LPS25H.h"

bool LPS25H::begin()
{
  int result = I2Cdev::readByte(LPS25H_ADDRESS, LPS25H_WHO_AM_I, buf);

  if (buf[0] != 0xBD) {
    Serial.println("Can't access LPS25H");
    return false;
  }

  isConnected = true;

  return true;
}

bool LPS25H::enable()
{
  if (isEnabled)
    return true;

  I2Cdev::writeByte(LPS25H_ADDRESS, LPS25H_CTRL_REG1, LPS25H_POWERON7HZ);

  isEnabled = true;
}

bool LPS25H::disable()
{
  I2Cdev::writeByte(LPS25H_ADDRESS, LPS25H_CTRL_REG1, LPS25H_POWERDOWN);

  isEnabled = false;
}

bool LPS25H::update()
{
  if (!isEnabled)
    return false;

  I2Cdev::readBytes(LPS25H_ADDRESS, 0x28 | 0x80, 3, buf);
  pressure = ((buf[2] * 65536) + (buf[1] * 256) + buf[0]) / 4096.0;
}


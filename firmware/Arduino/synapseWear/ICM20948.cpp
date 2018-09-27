/*
  Library for the ICM20948 9DoF sensor
  Created by Alexander Reeder, 2018 Jan 1

  MPU9250 code by Kris Winer was an invaluable resource!
*/
/* ============================================
  I2Cdev device library code is placed under the MIT license
  Copyright (c) 2011 Jeff Rowberg

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
  ===============================================
*/

#include "ICM20948.h"

// Checks its PART_ID. Returns false on I2C problems or wrong PART_ID.
bool ICM20948::begin() {
  uint8_t result = ICM20948::getDeviceID();
  if (result != ICM20948_PARTID) {
#ifdef ICM20948_SERIAL_DEBUG
    Serial.println("ICM20948: debug: unable to detect ICM20948");
#endif
    return false;
  }
  I2Cdev::writeByte(ICM20948_DEFAULT_ADDRESS, ICM20948_PWR_MGMT_1, 0x00);
  delay(100);
  I2Cdev::writeByte(ICM20948_DEFAULT_ADDRESS, ICM20948_PWR_MGMT_1, 0x01);
  delay(200);

  I2Cdev::writeByte(ICM20948_DEFAULT_ADDRESS, ICM20948_REG_BANK_SEL, 0x02); // user bank 2

  I2Cdev::writeByte(ICM20948_DEFAULT_ADDRESS, ICM20948_GYRO_SMPLRT_DIV, 0x04);
  I2Cdev::writeByte(ICM20948_DEFAULT_ADDRESS, ICM20948_ACCEL_SMPLRT_DIV_2, 0x04);

  I2Cdev::readByte(ICM20948_DEFAULT_ADDRESS, ICM20948_GYRO_CONFIG_1, buf);
  uint8_t c = buf[0];
  I2Cdev::writeByte(ICM20948_DEFAULT_ADDRESS, ICM20948_GYRO_CONFIG_1, c & ~0x03); // Clear Fchoice bits [1:0]
  I2Cdev::writeByte(ICM20948_DEFAULT_ADDRESS, ICM20948_GYRO_CONFIG_1, c & ~0x18); // Clear GFS bits [4:3]
  I2Cdev::writeByte(ICM20948_DEFAULT_ADDRESS, ICM20948_GYRO_CONFIG_1, c | ICM20948Gscale << 3); // Set full scale range for the gyro

  I2Cdev::readByte(ICM20948_DEFAULT_ADDRESS, ICM20948_ACCEL_CONFIG_1, buf);
  c = buf[0];
  //  writeRegister(ACCEL_CONFIG, c & ~0xE0); // Clear self-test bits [7:5]
  I2Cdev::writeByte(ICM20948_DEFAULT_ADDRESS, ICM20948_ACCEL_CONFIG_1, c & ~0x18); // Clear AFS bits [4:3]
  I2Cdev::writeByte(ICM20948_DEFAULT_ADDRESS, ICM20948_ACCEL_CONFIG_1, c | ICM20948Ascale << 3); // Set full scale range for the accelerometer

  I2Cdev::readByte(ICM20948_DEFAULT_ADDRESS, ICM20948_ACCEL_CONFIG_2, buf);
  c = buf[0];
  I2Cdev::writeByte(ICM20948_DEFAULT_ADDRESS, ICM20948_ACCEL_CONFIG_2, c & ~0x0F); // Clear accel_fchoice_b (bit 3) and A_DLPFG (bits [2:0])
  I2Cdev::writeByte(ICM20948_DEFAULT_ADDRESS, ICM20948_ACCEL_CONFIG_2, c | 0x03); // Set accelerometer rate to 1 kHz and bandwidth to 41 Hz

  I2Cdev::writeByte(ICM20948_DEFAULT_ADDRESS, ICM20948_REG_BANK_SEL, 0x00); // user bank 0

  I2Cdev::writeByte(ICM20948_DEFAULT_ADDRESS, ICM20948_INT_PIN_CFG, 0x22);
  I2Cdev::writeByte(ICM20948_DEFAULT_ADDRESS, ICM20948_INT_ENABLE, 0x01);  // Enable data ready (bit 0) interrupt

  isConnected = true;

  disable();

  return true;
}

uint8_t ICM20948::getDeviceID() {
  I2Cdev::readByte(ICM20948_DEFAULT_ADDRESS, ICM20948_WHO_AM_I, buf);
#ifdef ICM20948_SERIAL_DEBUG
  Serial.printf("ICM20948: debug: getDeviceID 0x%x\n", buf[0]);
#endif
  return buf[0];
}

bool ICM20948::enable() {
  if (isEnabled)
    return true;

  isEnabled = true;
}

bool ICM20948::disable() {
  for (int i = 0; i < 14; i++) {
    buf[i] = 0xff;
  }
  isEnabled = false;
}

bool ICM20948::update() {
  if (!isEnabled)
    return false;
    
  int result = I2Cdev::readBytes(ICM20948_DEFAULT_ADDRESS, ICM20948_ACCEL_XOUT_H, 12, buf);
  if (result != 12) {
#ifdef ICM20948_SERIAL_DEBUG
    Serial.printf("ICM20948: debug: update only %d bytes returned\n", result);
#endif
    return false;
  }
  // Accelerometer
  ax = -(buf[0] << 8 | buf[1]);
  ay = -(buf[2] << 8 | buf[3]);
  az = buf[4] << 8 | buf[5];

  // Gyroscope
  gx = -(buf[6] << 8 | buf[7]);
  gy = -(buf[8] << 8 | buf[9]);
  gz = buf[10] << 8 | buf[11];

  return true;
}

bool ICM20948::updateBuffer(byte *targetBuffer, byte *targetCount) {
  int result = I2Cdev::readBytes(ICM20948_DEFAULT_ADDRESS, ICM20948_ACCEL_XOUT_H, 12, buf);
  if (result != 12) {
#ifdef ICM20948_SERIAL_DEBUG
    Serial.printf("ICM20948: debug: update only %d bytes returned\n", result);
#endif
    return false;
  }

  for (int i = 0; i < 12; i++) {
    targetBuffer[*targetCount] = buf[i];
    *targetCount += 1;
  }

  return true;
}

uint8_t * ICM20948::getAccelGyroBuffer()
{
  return buf;
}

uint8_t ICM20948::lpConfig() {
  I2Cdev::readByte(ICM20948_DEFAULT_ADDRESS, ICM20948_LP_CONFIG, buf);
  return buf[0];
}

uint8_t ICM20948::userCtrl() {
  I2Cdev::readByte(ICM20948_DEFAULT_ADDRESS, ICM20948_USER_CTRL, buf);
  return buf[0];
}

uint8_t ICM20948::pwrMgmt1() {
  I2Cdev::readByte(ICM20948_DEFAULT_ADDRESS, ICM20948_PWR_MGMT_1, buf);
  return buf[0];
}

uint8_t ICM20948::pwrMgmt2() {
  I2Cdev::readByte(ICM20948_DEFAULT_ADDRESS, ICM20948_PWR_MGMT_2, buf);
  return buf[0];
}

uint8_t ICM20948::intStatus() {
  I2Cdev::readByte(ICM20948_DEFAULT_ADDRESS, ICM20948_INT_STATUS, buf);
  return buf[0];
}

uint8_t ICM20948::intStatus1() {
  I2Cdev::readByte(ICM20948_DEFAULT_ADDRESS, ICM20948_INT_STATUS_1, buf);
  return buf[0];
}

uint8_t ICM20948::getAccelConfig() {
  I2Cdev::readByte(ICM20948_DEFAULT_ADDRESS, ICM20948_ACCEL_CONFIG_1, buf);
  I2Cdev::readByte(ICM20948_DEFAULT_ADDRESS, ICM20948_ACCEL_CONFIG_2, buf);
  return buf[0];
}

uint8_t ICM20948::setAccelConfig2() {
  I2Cdev::writeByte(ICM20948_DEFAULT_ADDRESS, ICM20948_ACCEL_CONFIG_1, 0x1);
  I2Cdev::writeByte(ICM20948_DEFAULT_ADDRESS, ICM20948_ACCEL_CONFIG_2, 0x1);
  return buf[0];
}

uint8_t ICM20948::setAccelSmplrtDiv() {
  I2Cdev::writeByte(ICM20948_DEFAULT_ADDRESS, ICM20948_ACCEL_SMPLRT_DIV_1, 0x1);
  I2Cdev::writeByte(ICM20948_DEFAULT_ADDRESS, ICM20948_ACCEL_SMPLRT_DIV_2, 0x1);
  return buf[0];
}

uint8_t ICM20948::getRegBankSel() {
  I2Cdev::readByte(ICM20948_DEFAULT_ADDRESS, ICM20948_REG_BANK_SEL, buf);
  return buf[0];
}

uint8_t ICM20948::setRegBankSel(int userBank) {
  I2Cdev::writeByte(ICM20948_DEFAULT_ADDRESS, ICM20948_REG_BANK_SEL, userBank);
  return buf[0];
}

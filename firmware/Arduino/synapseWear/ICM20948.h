/*
  Library for the ICM20948 9DoF sensor
  Created by Alexander Reeder, 2018 Jan 1

  ICM20948 code by Kris Winer was an invaluable resource!
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

#ifndef _ICM20948_H_
#define _ICM20948_H_

#include "I2Cdev.h"

// comment out to disable debug
//#define ICM20948_SERIAL_DEBUG

#define ICM20948_ADDRESS_00           0x68               // A0 Low
#define ICM20948_ADDRESS_01           0x69               // A0 High
#define ICM20948_DEFAULT_ADDRESS      ICM20948_ADDRESS_00

#define ICM20948_PARTID               0xEA // The expected part id of the ICM20948

#define ICM20948_WHO_AM_I             0x00
#define ICM20948_USER_CTRL            0x03
#define ICM20948_LP_CONFIG            0x05
#define ICM20948_PWR_MGMT_1           0x06
#define ICM20948_PWR_MGMT_2           0x07
#define ICM20948_INT_PIN_CFG          0x0F
#define ICM20948_INT_ENABLE           0x10
#define ICM20948_INT_ENABLE_1         0x11
#define ICM20948_INT_ENABLE_2         0x12
#define ICM20948_INT_ENABLE_3         0x13
#define ICM20948_I2C_MST_STATUS       0x17
#define ICM20948_INT_STATUS           0x19
#define ICM20948_INT_STATUS_1         0x1A
#define ICM20948_INT_STATUS_2         0x1B
#define ICM20948_INT_STATUS_3         0x1C
#define ICM20948_DELAY_TIMEH          0x28
#define ICM20948_DELAY_TIMEL          0x29
#define ICM20948_ACCEL_XOUT_H         0x2D
#define ICM20948_ACCEL_XOUT_L         0x2E
#define ICM20948_ACCEL_YOUT_H         0x2F
#define ICM20948_ACCEL_YOUT_L         0x30
#define ICM20948_ACCEL_ZOUT_H         0x31
#define ICM20948_ACCEL_ZOUT_L         0x32
#define ICM20948_GYRO_XOUT_H          0x33
#define ICM20948_GYRO_XOUT_L          0x34
#define ICM20948_GYRO_YOUT_H          0x35
#define ICM20948_GYRO_YOUT_L          0x36
#define ICM20948_GYRO_ZOUT_H          0x37
#define ICM20948_GYRO_ZOUT_L          0x38
#define ICM20948_TEMP_OUT_H           0x39
#define ICM20948_TEMP_OUT_L           0x3A
#define ICM20948_EXT_SLV_SENS_DATA_00 0x3B
#define ICM20948_EXT_SLV_SENS_DATA_01 0x3C
#define ICM20948_EXT_SLV_SENS_DATA_02 0x3D
#define ICM20948_EXT_SLV_SENS_DATA_03 0x3E
#define ICM20948_EXT_SLV_SENS_DATA_04 0x3F
#define ICM20948_EXT_SLV_SENS_DATA_05 0x40
#define ICM20948_EXT_SLV_SENS_DATA_06 0x41
#define ICM20948_EXT_SLV_SENS_DATA_07 0x42
#define ICM20948_EXT_SLV_SENS_DATA_08 0x43
#define ICM20948_EXT_SLV_SENS_DATA_09 0x44
#define ICM20948_EXT_SLV_SENS_DATA_10 0x45
#define ICM20948_EXT_SLV_SENS_DATA_11 0x46
#define ICM20948_EXT_SLV_SENS_DATA_12 0x47
#define ICM20948_EXT_SLV_SENS_DATA_13 0x48
#define ICM20948_EXT_SLV_SENS_DATA_14 0x49
#define ICM20948_EXT_SLV_SENS_DATA_15 0x4A
#define ICM20948_EXT_SLV_SENS_DATA_16 0x4B
#define ICM20948_EXT_SLV_SENS_DATA_17 0x4C
#define ICM20948_EXT_SLV_SENS_DATA_18 0x4D
#define ICM20948_EXT_SLV_SENS_DATA_19 0x4E
#define ICM20948_EXT_SLV_SENS_DATA_20 0x4F
#define ICM20948_EXT_SLV_SENS_DATA_21 0x50
#define ICM20948_EXT_SLV_SENS_DATA_22 0x51
#define ICM20948_EXT_SLV_SENS_DATA_23 0x52
#define ICM20948_FIFO_EN_1            0x66
#define ICM20948_FIFO_EN_2            0x67
#define ICM20948_FIFO_RST             0x68
#define ICM20948_FIFO_MODE            0x69
#define ICM20948_FIFO_COUNTH          0x70
#define ICM20948_FIFO_COUNTL          0x71
#define ICM20948_FIFO_R_W             0x72
#define ICM20948_DATA_RDY_STATUS      0x74
#define ICM20948_FIFO_CFG             0x76
#define ICM20948_REG_BANK_SEL         0x7F

#define ICM20948_GYRO_SMPLRT_DIV    0x00
#define ICM20948_GYRO_CONFIG_1      0x01
#define ICM20948_GYRO_CONFIG_2      0x02
#define ICM20948_ACCEL_SMPLRT_DIV_1 0x10
#define ICM20948_ACCEL_SMPLRT_DIV_2 0x11
#define ICM20948_ACCEL_CONFIG_1       0x14
#define ICM20948_ACCEL_CONFIG_2     0x15
#define ICM20948_REG_BANK_SEL       0x7F
//#define ICM20948_         0x

class ICM20948 {
  public:
    bool begin();
    uint8_t getDeviceID();
    uint8_t userCtrl();
    uint8_t lpConfig();
    uint8_t pwrMgmt1();
    uint8_t pwrMgmt2();
    uint8_t intStatus();
    uint8_t intStatus1();
    bool update();
    bool enable();
    bool disable();
    bool updateBuffer(byte *targetBuffer, byte *targetCount);
    uint8_t getRegBankSel();
    uint8_t setRegBankSel(int userBank);
    uint8_t setAccelSmplrtDiv();
    uint8_t getAccelConfig();
    uint8_t setAccelConfig2();
    uint8_t * getAccelGyroBuffer();

    int16_t ax, ay, az, gx, gy, gz;

    bool isConnected = false;
    bool isEnabled = false;

  private:
    uint8_t buf[14];
    
    enum ICM20948Ascale {
      AFS_2G = 0,
      AFS_4G,
      AFS_8G,
      AFS_16G
    };

    enum ICM20948Gscale {
      GFS_250DPS = 0,
      GFS_500DPS,
      GFS_1000DPS,
      GFS_2000DPS
    };

    enum ICM20948Mscale {
      MFS_14BITS = 0, // 0.6 mG per LSB
      MFS_16BITS      // 0.15 mG per LSB
    };

    uint8_t ICM20948Gscale = GFS_250DPS;
    uint8_t ICM20948Ascale = AFS_2G;
    uint8_t ICM20948Mscale = MFS_16BITS; // Choose either 14-bit or 16-bit magnetometer resolution
    uint8_t ICM20948Mmode = 0x06;        // 2 for 8 Hz, 6 for 100 Hz continuous magnetometer data read
    float ICM20948aRes, ICM20948gRes, ICM20948mRes;             // scale resolutions per LSB for the sensors
};

#endif

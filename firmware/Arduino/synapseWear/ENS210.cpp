/*
  Library for the ENS210 relative humidity and temperature sensor with I2C interface from ams
  Created by Maarten Pennings 2017 Aug 2

  Forked and modified for I2Cdev by Alexander Reeder, 2017 Dec 31
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

#include <assert.h>
#include "ens210.h"

// Resets ENS210 and checks its PART_ID. Returns false on I2C problems or wrong PART_ID.
// Stores solder correction.
bool ENS210::begin(void) {
  bool ok;
  uint16_t partid;
  // Record solder correction
  _soldercorrection = 0;
  // Reset, get and check partid
  ok = reset();
  if (!ok)
    return false;
  ok = getVersion(&partid, NULL);
  if (!ok)
    return false;
  if ( partid != ENS210_PARTID )
    return false;
  // Success
  
  isConnected = true;

  disable();

  return true;
}

// Performs one single shot temperature and relative humidity measurement.
void ENS210::measure(int * t_data, int * t_status, int * h_data, int * h_status ) {
  bool ok;
  uint32_t t_val;
  uint32_t h_val;
  // Set default status for early bail out
  *t_status = ENS210_STATUS_I2CERROR;
  *h_status = ENS210_STATUS_I2CERROR;
  // Start a single shot measurement
  ok = startsingle(); if (!ok) return;
  // Wait for measurement to complete
  delay(ENS210_THCONVERSIONTIME);
  // Get the measurement data
  ok = read(&t_val, &h_val); if (!ok) return;
  // Extract the data and status
  extract(t_val, t_data, t_status);
  extract(h_val, h_data, h_status);
}

bool ENS210::enable() {
  if (isEnabled)
    return true;

  int result = I2Cdev::writeByte(ENS210_DEFAULT_ADDRESS, ENS210_REG_SYS_CTRL, 0x00);
  isEnabled = true;
}

bool ENS210::disable() {
  int result = I2Cdev::writeByte(ENS210_DEFAULT_ADDRESS, ENS210_REG_SYS_CTRL, 0x01);
  celsius = 255.0f;
  percentageH = 255;
  isEnabled = false;
}

bool ENS210::update() {
  if (!isEnabled)
    return false;
  bool ok;
  uint32_t t_val;
  uint32_t h_val;
  // Set default status for early bail out
  t_status = ENS210_STATUS_I2CERROR;
  h_status = ENS210_STATUS_I2CERROR;
  // Start a single shot measurement
  ok = startsingle(); if (!ok) return false;
  // Wait for measurement to complete
  delay(ENS210_THCONVERSIONTIME);
  // Get the measurement data
  ok = read(&t_val, &h_val); if (!ok) return false;
  // Extract the data and status
  extract(t_val, &t_data, &t_status);
  extract(h_val, &h_data, &h_status);
  celsius = toCelsius(t_data,10)/10.0;
  percentageH = toPercentageH(h_data,1);
  return true;
}

// Sends a reset to the ENS210. Returns false on I2C problems.
bool ENS210::reset(void) {
  int result = I2Cdev::writeByte(ENS210_DEFAULT_ADDRESS, ENS210_REG_SYS_CTRL, 0x80);
#ifdef ENS210_SERIAL_DEBUG
  Serial.printf("ENS210: debug: reset %d\n", result);
#endif
  delay(ENS210_BOOTING);                   // Wait to boot after reset
  return result;
}

// Sets ENS210 to low (true) or high (false) power. Returns false on I2C problems.
bool ENS210::lowPower(bool enable) {
  uint8_t power = { enable ? 0x01 : 0x00 };
  int result = I2Cdev::writeByte(ENS210_DEFAULT_ADDRESS, ENS210_REG_SYS_CTRL, power);
#ifdef ENS210_SERIAL_DEBUG
  Serial.printf("ENS210: debug: lowPower(%d) %d\n", power, result);
#endif
  delay(ENS210_BOOTING);                   // Wait boot-time after power switch
  return result;
}

// Reads PART_ID and UID of ENS210. Returns false on I2C problems.
bool ENS210::getVersion(uint16_t*partid, uint64_t*uid) {
  bool ok;
  uint8_t buf[8];
  int result;

  // Must disable low power to read PART_ID or UID
  ok = lowPower(false); if (!ok) goto errorexit;

  // Read the PART_ID
  if ( partid != 0 ) {
    int result = I2Cdev::readBytes(ENS210_DEFAULT_ADDRESS, ENS210_REG_PART_ID, 2, buf);
#ifdef ENS210_SERIAL_DEBUG
    Serial.printf("ENS210: debug: getVersion/part_id %d\n", result);
#endif
    if ( result == -1 )
      goto errorexit;
    *partid = buf[1] * 256U + buf[0] * 1U;
  }

  // Read the UID
  if ( uid != 0 ) {
    int result = I2Cdev::readBytes(ENS210_DEFAULT_ADDRESS, ENS210_REG_UID, 8, buf);
#ifdef ENS210_SERIAL_DEBUG
    Serial.printf("ENS210: debug: getVersion/uid %d\n", result);
#endif
    if ( result != 0 )
      goto errorexit;
    // Retrieve and pack bytes into uid (ignore the endianness)
    for ( int i = 0; i < 8; i++)
      ((uint8_t*)uid)[i] = buf[i];
  }

  // Go back to default power mode (low power enabled)
  ok = lowPower(true);
  if (!ok)
    goto errorexit;

  // { uint32_t hi= *uid >>32, lo= *uid & 0xFFFFFFFF; Serial.printf("ENS210: debug: PART_ID=%04x UID=%08x %08x\n",*partid,hi,lo); }
  // Success
  return true;

errorexit:
  // Try to go back to default mode (low power enabled)
#ifdef ENS210_SERIAL_DEBUG
  Serial.println("ENS210: debug: getVersion errorexit");
#endif
  ok = lowPower(true);
  // Hopefully enabling low power was successful; but there was an error before that anyhow
  return false;
}

// Configures ENS210 to perform a single measurement. Returns false on I2C problems.
bool ENS210::startsingle(void) {
  uint8_t buf[2] = { 0x00, 0x03 };
  int result = I2Cdev::writeBytes(ENS210_DEFAULT_ADDRESS, ENS210_REG_SENS_RUN, 2, buf);
#ifdef ENS210_SERIAL_DEBUG
  Serial.printf("ENS210: debug: startsingle %d\n", result);
#endif
  return result;
}

// Reads measurement data from the ENS210. Returns false on I2C problems.
bool ENS210::read(uint32_t *t_val, uint32_t *h_val) {
  uint8_t buf[6];
  // Read T_VAL and H_VAL
  int result = I2Cdev::readBytes(ENS210_DEFAULT_ADDRESS, ENS210_REG_T_VAL, 6, buf);
  if ( result == -1 )
    return false;
  *t_val = (buf[2] * 65536UL) + (buf[1] * 256UL) + (buf[0] * 1UL);
  *h_val = (buf[5] * 65536UL) + (buf[4] * 256UL) + (buf[3] * 1UL);
  // Range checking
  //if( *t_val<(273-100)*64 || *t_val>(273+150)*64 ) return false; // Accept only readouts -100<=T_in_C<=+150 (arbitrary limits)
  //if( *h_val>100*512 ) return false; // Accept only readouts 0<=H<=100
  // Success
  return true;
}

// Extracts measurement `data` and `status` from a `val` obtained from `read`.
// Upon entry, 'val' is the 24 bits read from T_VAL or H_VAL.
// Upon exit, 'data' is the T_DATA or H_DATA, and 'status' one of ENS210_STATUS_XXX.
void ENS210::extract(uint32_t val, int * data, int * status) {
  // Destruct 'val'
  * data           = (val >> 0 ) & 0xffff;
  int valid        = (val >> 16) & 0x1;
  uint32_t crc     = (val >> 17) & 0x7f;
  uint32_t payload = (val >> 0 ) & 0x1ffff;
  int crc_ok = crc7(payload) == crc;
  // Check CRC and valid bit
  if ( !crc_ok ) *status = ENS210_STATUS_CRCERROR;
  else if ( !valid ) *status = ENS210_STATUS_INVALID;
  else *status = ENS210_STATUS_OK;
}

// Converts a status (ENS210_STATUS_XXX) to a human readable string.
const char * ENS210::status_str( int status ) {
  switch ( status ) {
    case ENS210_STATUS_I2CERROR : return "i2c-error";
    case ENS210_STATUS_CRCERROR : return "crc-error";
    case ENS210_STATUS_INVALID  : return "data-invalid";
    case ENS210_STATUS_OK       : return "ok";
    default                     : return "unknown-status";
  }
}

// Convert raw `t_data` temperature to Kelvin (also applies the solder correction).
// The output value is in Kelvin multiplied by parameter `multiplier`.
int32_t ENS210::toKelvin(int t_data, int multiplier) {
  assert( (1 <= multiplier) && (multiplier <= 1024) );
  // Force 32 bits
  int32_t t = t_data & 0xFFFF;
  // Compensate for soldering effect
  t -= _soldercorrection;
  // Return m*K. This equals m*(t/64) = (m*t)/64
  // Note m is the multiplier, K is temperature in Kelvin, t is raw t_data value.
  // Uses K=t/64.
  return IDIV(multiplier * t, 64);
}

// Convert raw `t_data` temperature to Celsius (also applies the solder correction).
// The output value is in Celsius multiplied by parameter `multiplier`.
int32_t ENS210::toCelsius(int t_data, int multiplier) {
  assert( (1 <= multiplier) && (multiplier <= 1024) );
  // Force 32 bits
  int32_t t = t_data & 0xFFFF;
  // Compensate for soldering effect
  t -= _soldercorrection;
  // Return m*C. This equals m*(K-273.15) = m*K - 27315*m/100 = m*t/64 - 27315*m/100
  // Note m is the multiplier, C is temperature in Celsius, K is temperature in Kelvin, t is raw t_data value.
  // Uses C=K-273.15 and K=t/64.
  return IDIV(multiplier * t, 64) - IDIV(27315L * multiplier, 100);
}

// Convert raw `t_data` temperature to Fahrenheit (also applies the solder correction).
// The output value is in Fahrenheit multiplied by parameter `multiplier`.
int32_t ENS210::toFahrenheit(int t_data, int multiplier) {
  assert( (1 <= multiplier) && (multiplier <= 1024) );
  // Force 32 bits
  int32_t t = t_data & 0xFFFF;
  // Compensate for soldering effect
  t -= _soldercorrection;
  // Return m*F. This equals m*(1.8*(K-273.15)+32) = m*(1.8*K-273.15*1.8+32) = 1.8*m*K-459.67*m = 9*m*K/5 - 45967*m/100 = 9*m*t/320 - 45967*m/100
  // Note m is the multiplier, F is temperature in Fahrenheit, K is temperature in Kelvin, t is raw t_data value.
  // Uses F=1.8*(K-273.15)+32 and K=t/64.
  return IDIV(9 * multiplier * t, 320) - IDIV(45967L * multiplier, 100);
  // The first multiplication stays below 32 bits (t:16, multiplier:11, 9:4)
  // The second multiplication stays below 32 bits (multiplier:10, 45967:16)
}

// Convert raw `h_data` relative humidity to %RH.
// The output value is in %RH multiplied by parameter `multiplier`.
int32_t ENS210::toPercentageH(int h_data, int multiplier) {
  assert( (1 <= multiplier) && (multiplier <= 1024) );
  // Force 32 bits
  int32_t h = h_data & 0xFFFF;
  // Return m*H. This equals m*(h/512) = (m*h)/512
  // Note m is the multiplier, H is the relative humidity in %RH, h is raw h_data value.
  // Uses H=h/512.
  return IDIV(multiplier * h, 512);
}

// Sets the solder correction (default is 50mK) - only used by the `toXxx` functions.
void ENS210::correction_set(int correction) {
  assert( -1 * 64 < correction && correction < +1 * 64 ); // A correction of more than 1 Kelvin does not make sense (but the 1K is arbitrary)
  _soldercorrection = correction;
}

int ENS210::correction_get(void) {
  return _soldercorrection;
}

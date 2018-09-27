/*
  Library for the ENS210 relative humidity and temperature sensor with I2C interface from ams
  Created by Maarten Pennings 2017 Aug 1

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

#ifndef _ENS210_H_
#define _ENS210_H_

#include <stdint.h>
#include "I2Cdev.h"

//#define ENS210_SERIAL_DEBUG

#define ENS210_DEFAULT_ADDRESS      0x43
#define ENS210_PARTID               0x0210 // The expected part id of the ENS210
#define ENS210_THCONVERSIONTIME     130 // Conversion time in ms for one T/H measurement
#define ENS210_BOOTING              2 // Booting time in ms (also after reset, or going to high power)

// Addresses of the ENS210 registers
#define ENS210_REG_PART_ID       0x00
#define ENS210_REG_UID           0x04
#define ENS210_REG_SYS_CTRL      0x10
#define ENS210_REG_SYS_STAT      0x11
#define ENS210_REG_SENS_RUN      0x21
#define ENS210_REG_SENS_START    0x22
#define ENS210_REG_SENS_STOP     0x23
#define ENS210_REG_SENS_STAT     0x24
#define ENS210_REG_T_VAL         0x30
#define ENS210_REG_H_VAL         0x33

// Measurement status as output by `measure()` and `extract()`.
// Note that the ENS210 provides a "value" (`t_val` or `h_val` each 24 bit).
// A "value" consists of a payload (17 bit) and a CRC (7 bit) over that payload.
// The payload consists of a valid flag (1 bit) and the actual measurement "data" (`t_data` or `h_data`, 16 bit)
#define ENS210_STATUS_I2CERROR  4 // There was an I2C communication error, `read`ing the value.
#define ENS210_STATUS_CRCERROR  3 // The value was read, but the CRC over the payload (valid and data) does not match.
#define ENS210_STATUS_INVALID   2 // The value was read, the CRC matches, but the data is invalid (e.g. the measurement was not yet finished).
#define ENS210_STATUS_OK        1 // The value was read, the CRC matches, and data is valid.

// Division macro (used in conversion functions), implementing integer division with rounding.
// It supports both positive and negative dividends (n), but ONLY positive divisors (d).
#define IDIV(n,d)                ((n)>0 ? ((n)+(d)/2)/(d) : ((n)-(d)/2)/(d))

//               7654 3210
// Polynomial 0b 1000 1001 ~ x^7+x^3+x^0
//            0x    8    9
#define CRC7WIDTH  7    // A 7 bits CRC has polynomial of 7th order, which has 8 terms
#define CRC7POLY   0x89 // The 8 coefficients of the polynomial
#define CRC7IVEC   0x7F // Initial vector has all 7 bits high
// Payload data
#define DATA7WIDTH 17
#define DATA7MASK  ((1UL<<DATA7WIDTH)-1) // 0b 0 1111 1111 1111 1111
#define DATA7MSB   (1UL<<(DATA7WIDTH-1)) // 0b 1 0000 0000 0000 0000
// Compute the CRC-7 of 'val' (should only have 17 bits)
// https://en.wikipedia.org/wiki/Cyclic_redundancy_check#Computation
static uint32_t crc7( uint32_t val ) {
  // Setup polynomial
  uint32_t pol = CRC7POLY;
  // Align polynomial with data
  pol = pol << (DATA7WIDTH - CRC7WIDTH - 1);
  // Loop variable (indicates which bit to test, start with highest)
  uint32_t bit = DATA7MSB;
  // Make room for CRC value
  val = val << CRC7WIDTH;
  bit = bit << CRC7WIDTH;
  pol = pol << CRC7WIDTH;
  // Insert initial vector
  val |= CRC7IVEC;
  // Apply division until all bits done
  while ( bit & (DATA7MASK << CRC7WIDTH) ) {
    if ( bit & val ) val ^= pol;
    bit >>= 1;
    pol >>= 1;
  }
  return val;
}

class ENS210 {
  public: // Main API functions
    // Resets ENS210 and checks its PART_ID. Returns false on I2C problems or wrong PART_ID.
    bool begin(void);
    // Performs one single shot temperature and relative humidity measurement.
    // Sets `t_data` (temperature in 1/64K), and `t_status` (from ENS210STATUS_XXX).
    // Sets `h_data` (relative humidity in 1/512 %RH), and `h_status` (from ENS210STATUS_XXX).
    // Use the conversion functions below to convert `t_data` to K, C, F; or `h_data` to %RH.
    // Note that this function contains a delay of 130ms to wait for the measurement to complete.
    void measure(int * t_data, int * t_status, int * h_data, int * h_status );
    bool update();
    bool enable();
    bool disable();

  public: // Conversion functions - the temperature conversions also subtract the solder correction (see correction_set() method).
    int32_t toKelvin     (int t_data, int multiplier); // Converts t_data (from `measure`) to multiplier*Kelvin
    int32_t toCelsius    (int t_data, int multiplier); // Converts t_data (from `measure`) to multiplier*Celsius
    int32_t toFahrenheit (int t_data, int multiplier); // Converts t_data (from `measure`) to multiplier*Fahrenheit
    int32_t toPercentageH(int h_data, int multiplier); // Converts h_data (from `measure`) to multiplier*%RH

    // Optionally set a solder `correction` (units: 1/64K, default from `begin` is 0).
    // See "Effect of Soldering on Temperature Readout" in "Design-Guidelines" from
    // https://download.ams.com/ENVIRONMENTAL-SENSORS/ENS210/Documentation
    void correction_set(int correction = 50 * 64 / 1000); // Sets the solder correction (default is 50mK) - only used by the `toXxx()` functions.
    int  correction_get(void);                      // Gets the solder correction.

  public: // Helper functions (communicating with ENS210)
    bool reset(void);                                  // Sends a reset to the ENS210. Returns false on I2C problems.
    bool lowPower(bool enable);                        // Sets ENS210 to low (true) or high (false) power. Returns false on I2C problems.
    bool getVersion(uint16_t*partid, uint64_t*uid);    // Reads PART_ID and UID of ENS210. Returns false on I2C problems.
    bool startsingle(void);                            // Configures ENS210 to perform one single shot measurement. Returns false on I2C problems.
    bool read(uint32_t*t_val, uint32_t*h_val);         // Reads measurement data from the ENS210. Returns false on I2C problems.
    float celsius = 0.0f;
    int percentageH;
    bool isConnected = false;
    bool isEnabled = false;

  public: // Helper functions (data conversion)
    void extract(uint32_t val, int*data, int*status);  // Extracts measurement `data` and `status` from a `val` obtained from `read()`.
    const char * status_str( int status );             // Converts a status (ENS210_STATUS_XXX) to a human readable string.

  private: // Data members
    int _soldercorrection;                             // Correction due to soldering (in 1/64K); subtracted from `t_data` by conversion functions.
    int t_data, t_status, h_data, h_status;

};

#endif

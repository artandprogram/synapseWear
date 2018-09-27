// LPS25H library for synapseWear

#include "LPS25H.h"
#include "Wire.h"

// TODO
// use I2C
// change for intervals
// sleep

bool LPS25H::begin()
{
  isConnected = true;

  Wire.beginTransmission(LPS25H_ADDRESS);
  // Select control register 1
  Wire.write(0x20);
  // Set active mode, continuous Update
  Wire.write(0x90);
  // Stop I2C Transmission
  Wire.endTransmission();

  return true;
}

bool LPS25H::enable()
{
  if (isEnabled)
    return true;

  //writeRegister(MODE_REGISTER, 0x20, 0x00);

  isEnabled = true;
}

bool LPS25H::disable()
{
//  writeRegister(MODE_REGISTER, 0x20, 0x01);
//  for (int i = 0; i < 4; i++) {
//    buf[i] = 0xff;
//  }

  isEnabled = false;
}

bool LPS25H::update()
{
  if (!isEnabled)
    return false;

  unsigned int data[3];
  // Start I2C Transmission
  Wire.beginTransmission(LPS25H_ADDRESS);
  // Select pressure data register
  Wire.write(0x28 | 0x80);
  // Stop I2C Transmission
  Wire.endTransmission();

  // Request 3 bytes of data
  Wire.requestFrom(LPS25H_ADDRESS, 3);

  // Read 3 bytes of data
  // pressure lsb first
  if (Wire.available() == 3)
  {
    data[0] = Wire.read();
    data[1] = Wire.read();
    data[2] = Wire.read();
  }

  // Convert pressure data
  pressure = ((data[2] * 65536) + (data[1] * 256) + data[0]) / 4096.0;

  // Output data to serial monitor
//  Serial.print("Pressure is : ");
//  Serial.print(pressure);
//  Serial.println(" hPa");
  
//  voltage = getVCell();
//  stateOfCharge = getSoC();
}


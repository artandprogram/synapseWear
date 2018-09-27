/*
 * Created by boerisfrusca
 * https://github.com/boerisfrusca/Arduino
 * 
 * Forked and modified for synapseWear
 */
#include "TCA6507.h"
#include "Wire.h"
#include <SimbleeBLE.h>


#if ARDUINO >= 100
#include "Arduino.h"       // for delayMicroseconds, digitalPinToBitMask, etc
#else
#include "WProgram.h"      // for delayMicroseconds
#include "pins_arduino.h"  // for digitalPinToBitMask, etc
#endif

TCA6507::TCA6507(uint8_t PIN_VDD, uint8_t PIN_BATTCHG) {	// Setup will map IC reset pin, start I2C communications, and put device in shutdown mode.
  _PIN_VDD = PIN_VDD;
  pinMode(_PIN_VDD, OUTPUT);
  digitalWrite(_PIN_VDD, LOW);
  _PIN_BATTCHG = PIN_BATTCHG;
}

bool TCA6507::begin() {	// Power IC from shutdown mode.
  isConnected = true;

  disable();

  return true;
}

void TCA6507::enable() {  // Power IC from shutdown mode.
  if (isEnabled)
    return;

  isEnabled = true;
}

void TCA6507::powerOn() {
  digitalWrite(_PIN_VDD, HIGH);
  isReady = true;
}

void TCA6507::disable() {	// Reset registers and put IC in shutdown mode.
  isEnabled = false;
  if (isCharging) {
    return;
  }
  Pinsetst(P1, pOff);
  Pinsetst(P2, pOff);
  Pinsetst(P3, pOff);
  digitalWrite(_PIN_VDD, LOW);
  isReady = false;
}

void TCA6507::powerOff() {
  Pinsetst(P1, pOff);
  Pinsetst(P2, pOff);
  Pinsetst(P3, pOff);
  digitalWrite(_PIN_VDD, LOW);
  isReady = false;
}

void TCA6507::update()
{
  if (!isEnabled)
    return;

  if (!isCharging) {
    if (digitalRead(_PIN_BATTCHG) == LOW) {
      beginCharging();
    }
  }
  
  if (state == 1) {
    if (!isReady) {
      powerOn();
    }
    Bbanksetup(Bbank0, TMS0, TMS1024, TMS0, TMS16320, TMS0);
    RegtBank(Bbank0, maxinten, 1);
    Pinsetst(P1, Flashbank0);
    Pinsetst(P2, Flashbank0);
    Pinsetst(P3, Flashbank0);
    state = 2;
    timeToDisable = millis() + 1024;
  }
  else if (state == 2) {
    if (millis() > timeToDisable) {
      state = 0;
      if (isCharging) {
        Bbanksetup(Bbank0, TMS0, TMS16320, TMS0, TMS0, TMS0);
        RegtBank(Bbank0, maxinten, 3);
        Bbanksetup(Bbank1, TMS0, TMS16320, TMS0, TMS0, TMS0);
        RegtBank(Bbank1, maxinten, 1);
        Pinsetst(P1, Flashbank0);
        Pinsetst(P2, Flashbank1);
        Pinsetst(P3, pOff);
      }
      else {
        powerOff();
      }
    }
  }
}

void TCA6507::ping()
{
  state = 1;
}

void TCA6507::beginCharging()
{
  Serial.println("beginCharging()");
  powerOn();
  // TODO: save current state of LED
  Bbanksetup(Bbank0, TMS0, TMS16320, TMS0, TMS0, TMS0);
  RegtBank(Bbank0, maxinten, 3);
  Bbanksetup(Bbank1, TMS0, TMS16320, TMS0, TMS0, TMS0);
  RegtBank(Bbank1, maxinten, 1);
  Pinsetst(P1, Flashbank0);
  Pinsetst(P2, Flashbank1);
  Pinsetst(P3, pOff);
  isCharging = true;
}

void TCA6507::endCharging()
{
  Serial.println("endCharging()");
  powerOff();
  // TODO: restore previous state of LED
  isCharging = false;
}

void TCA6507::RAWRegDrv(uint8_t Regtset, uint8_t VTS) { // RAW registry drive for reg 3 thru reg 10.
  if (Regtset >= 3 && Regtset <= 10) {
    Wire.beginTransmission(TCAdevaddr);
    Wire.write(Regtset);
    Wire.write(VTS);
    Wire.endTransmission();
  }
}

void TCA6507::RAWSRDrv(int S0, int S1, int S2) {	// RAW Select Registers Drive for setting all pins at the same time by using auto-increment mode.

  Wire.beginTransmission(TCAdevaddr);
  Wire.write(0x10);
  Wire.write(S0);
  Wire.write(S1);
  Wire.write(S2);
  Wire.endTransmission();
}


uint8_t TCA6507::Rreg(uint8_t SRN) {	// Read register data

  Wire.beginTransmission(TCAdevaddr);
  Wire.write(SRN);
  Wire.endTransmission();

  Wire.requestFrom(TCAdevaddr, 1);
  uint8_t result = Wire.read();
  Wire.endTransmission();
  delay(1);
  return result;
}

uint8_t TCA6507::Cpnstate(uint8_t SPS) {	// Current pin state

  if (SPS >= 0 && SPS <= 6) {
    uint8_t SR0 = Rreg(0);
    SR0 = bitRead(SR0, SPS);
    uint8_t SR1 = Rreg(1);
    SR1 = bitRead(SR1, SPS);
    uint8_t SR2 = Rreg(2);
    SR2 = bitRead(SR2, SPS);

    pinstate = 0;
    if (SR0 == 1) pinstate += 1;
    if (SR1 == 1) pinstate += 2;
    if (SR2 == 1) pinstate += 4;
  }

  else pinstate = 16;

  return pinstate;
}

void TCA6507::Pinsetst(uint8_t pintc, uint8_t newpinst) {	// Sets specified pin to specified mode. Used for driving separate pins.

  if (pintc >= 0 && pintc <= 6 && newpinst >= 0 && newpinst <= 7) {
    uint8_t SR0 = Rreg(0);
    uint8_t SR0b = 0;
    uint8_t SR1 = Rreg(1);
    uint8_t SR1b = 0;
    uint8_t SR2 = Rreg(2);
    uint8_t SR2b = 0;

    if (newpinst == OnPWM0) {
      SR0b = 0;
      SR1b = 1;
      SR2b = 0;
    }
    else if (newpinst == OnPWM1) {
      SR0b = 1;
      SR1b = 1;
      SR2b = 0;
    }
    else if (newpinst == pOn) {
      SR0b = 0;
      SR1b = 0;
      SR2b = 1;
    }

    else if (newpinst == Ononeshot) {
      SR0b = 1;
      SR1b = 0;
      SR2b = 1;
    }
    else if (newpinst == Flashbank0) {
      SR0b = 0;
      SR1b = 1;
      SR2b = 1;
    }
    else if (newpinst == Flashbank1) {
      SR0b = 1;
      SR1b = 1;
      SR2b = 1;
    }

    SR0 = bitWrite(SR0, pintc, SR0b);
    SR1 = bitWrite(SR1, pintc, SR1b);
    SR2 = bitWrite(SR2, pintc, SR2b);
    RAWSRDrv(SR0, SR1, SR2);
  }
}

void TCA6507::Bbanksetup(uint8_t BankN, uint8_t FadeOn, uint8_t OnTime, uint8_t FadeOff, uint8_t OffTime, uint8_t SDOffTime) {		// Setup of flash and fade banks using one command per bank.

  if (BankN >= 0 && BankN <= 1 && FadeOn >= 0 && FadeOn <= 15 && OnTime >= 0 && OnTime <= 15 && FadeOff >= 0 && FadeOff <= 15 && OffTime >= 0 && OffTime <= 15 && SDOffTime >= 0 && SDOffTime <= 15) {
    uint8_t SR3 = Rreg(fadeont);
    uint8_t SR4 = Rreg(fullyont);
    uint8_t SR5 = Rreg(fadeofft);
    uint8_t SR6 = Rreg(ffullyofft);
    uint8_t SR7 = Rreg(sfullyofft);

    if (BankN == 0) {
      SR3 = SR3 & 0xF0;
      SR4 = SR4 & 0xF0;
      SR5 = SR5 & 0xF0;
      SR6 = SR6 & 0xF0;
      SR7 = SR7 & 0xF0;
    }

    if (BankN == 1) {

      SR3 = SR3 & 0x0F;
      SR4 = SR4 & 0x0F;
      SR5 = SR5 & 0x0F;
      SR6 = SR6 & 0x0F;
      SR7 = SR7 & 0x0F;

      FadeOn = FadeOn << 4;
      OnTime = OnTime << 4;
      FadeOff = FadeOff << 4;
      OffTime = OffTime << 4;
      SDOffTime = SDOffTime << 4;
    }

    SR3 = SR3 | FadeOn;
    SR4 = SR4 | OnTime;
    SR5 = SR5 | FadeOff;
    SR6 = SR6 | OffTime;
    SR7 = SR7 | SDOffTime;

    RAWRegDrv(fadeont, SR3);
    RAWRegDrv(fullyont, SR4);
    RAWRegDrv(fadeofft, SR5);
    RAWRegDrv(ffullyofft, SR6);
    RAWRegDrv(sfullyofft, SR7);

  }
}

void TCA6507::RegtBank(uint8_t BankN, uint8_t SRegN, uint8_t RegBV) { // Modify single bank value without effecting second bank

  if (BankN >= 0 && BankN <= 1 && SRegN >= 3 && SRegN <= 8 && RegBV >= 0 && RegBV <= 15) {
    uint8_t ResData = Rreg(SRegN);

    if (BankN == 0) ResData = ResData & 0xF0;

    if (BankN == 1) {
      ResData = ResData & 0x0F;
      RegBV = RegBV << 4;
    }

    ResData = ResData | RegBV;
    RAWRegDrv(SRegN, ResData);

  }
}

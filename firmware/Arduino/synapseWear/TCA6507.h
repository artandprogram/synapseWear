/*
 * Created by boerisfrusca
 * https://github.com/boerisfrusca/Arduino
 * 
 * Forked and modified for synapseWear
 */
#ifndef TCA6507_h
#define TCA6507_h

#if ARDUINO >= 100
#include "Arduino.h"       // for delayMicroseconds, digitalPinToBitMask, etc
#else
#include "WProgram.h"      // for delayMicroseconds
#include "pins_arduino.h"  // for digitalPinToBitMask, etc
#endif

// Registry
#define TCAdevaddr 0x45
#define sel0 0x00
#define sel1 0x01
#define sel2 0x02
#define fadeont 0x03
#define fullyont 0x04
#define fadeofft 0x05
#define ffullyofft 0x06
#define sfullyofft 0x07
#define maxinten 0x08
#define oneshotmi 0x09
#define initialization 0x0A

#define P1 0x00
#define P2 0x01
#define P3 0x02
#define P4 0x03
#define P5 0x04
#define P6 0x05
#define P7 0x06

#define pOff 0x00
#define OnPWM0 0x02
#define OnPWM1 0x03
#define pOn 0x04
#define Ononeshot 0x05
#define Flashbank0 0x06
#define Flashbank1 0x07

#define TMS0 0x00
#define TMS64 0x01
#define TMS128 0x02
#define TMS192 0x03
#define TMS256 0x04
#define TMS384 0x05
#define TMS512 0x06
#define TMS768 0x07
#define TMS1024 0x08
#define TMS1536 0x09
#define TMS2048 0x0A
#define TMS3072 0x0B
#define TMS4096 0x0C
#define TMS5760 0x0D
#define TMS8128 0x0E
#define TMS16320 0x0F

#define Bbank0 0x00
#define Bbank1 0x01

class TCA6507
{

  public:

    TCA6507(uint8_t PIN_VDD, uint8_t PIN_BATTCHG);
    void RAWSRDrv(int S0, int S1, int S2); // RAW Select Register Drive
    bool begin();
    void enable();
    void disable();
    void powerOn();
    void powerOff();
    void update();
    void ping();
    void beginCharging();
    void endCharging();
    uint8_t Rreg(uint8_t);	// RAW Registry read
    uint8_t pinstate;
    uint8_t pinwstate;
    uint8_t Cpnstate(uint8_t);
    void Pinsetst(uint8_t, uint8_t);
    void RAWRegDrv(uint8_t, uint8_t);
    void Bbanksetup(uint8_t, uint8_t, uint8_t, uint8_t, uint8_t, uint8_t);
    void RegtBank(uint8_t, uint8_t, uint8_t);

    bool isConnected = false;
    bool isEnabled = false;
    bool isReady = false;
    bool isCharging = false;

  private:

    uint8_t _PIN_VDD;
    uint32_t _PIN_BATTCHG;
    uint8_t state;
    uint32_t timeToDisable;

};

#endif

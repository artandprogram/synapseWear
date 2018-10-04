/*
  Library for synapseWear
  Created by Alexander Reeder, 2017 Apr 1
  For license and other information refer to https://github.com/artandprogram/synapseWear
*/

#ifndef _SYNAPSEWEAR_H
#define _SYNAPSEWEAR_H

#include "APDS9250.h"
#include "BM1383AGLV.h"
#include "LPS25H.h"
#include "CCS811.h"
#include "ENS210.h"
#include "ICM20948.h"
#include "MAX17048.h"
#include "SPH1642HT5H.h"
#include "TCA6507.h"

#define FIRMWARE_VERSION_MAJOR 1
#define FIRMWARE_VERSION_MINOR 3
#define FIRMWARE_DATE 20181004

#define PIN_AUD       3
#define PIN_BATTCHG   7
#define PIN_WAKEAIR   17
#define PIN_VDDAUD    18
#define PIN_INTAIR    19
#define PIN_VDDLIGHT  20
#define PIN_INTACCEL  23
#define PIN_ENLED     29
#define PIN_INTBATT   30

#define MODE_NORMAL     0x00
#define MODE_LIVE       0x01
#define MODE_LOWPOWER   0x02


#define SYNAPSEWEAR_SETTINGS_FLASH  230 // 240 - 251 used by ota_bootloader
#define SYNAPSEWEAR_INITIALIZED_VALUE 12345678
#define DEFAULT_INTERVAL 60000

class SYNAPSEWEAR {

  public:

    void begin();
    void pingI2C();
    void update();
    void setInterval(uint32_t);
    void bleOnConnect();
    void bleOnDisconnect();
    void bleOnReceive(char *, int);
    void beginCharging();
    void endCharging();

    APDS9250 apds9250 = APDS9250();
    BM1383AGLV bm1383aglv = BM1383AGLV();
    LPS25H lps25h = LPS25H();
    CCS811 ccs811 = CCS811(PIN_WAKEAIR);
    ENS210 ens210 = ENS210();
    ICM20948 icm20948 = ICM20948();
    MAX17048 max17048 = MAX17048();
    SPH1642HT5H sph1642ht5h = SPH1642HT5H(PIN_VDDAUD, PIN_AUD);
    TCA6507 tca6507 = TCA6507(PIN_ENLED, PIN_BATTCHG);

  private:

    void bleUpdate();
    void bleDataPrep();
    void bleDataDone();
    void bleDataCopy(uint8_t *, uint8_t);
    void bleDataUint8(uint8_t);
    void bleDataUint16(uint16_t);
    void bleDataFloatUint8(float);
    void bleDataFloatUint16(float);
    void bleShowData();
    void saveFirmwareSettings();
    bool validateAccessKey(char *, uint8_t);
    void enableSensors();
    void disableSensors();

    char *deviceName = "synapse";
    struct synapseWearSettings_t
    {
      uint32_t initialized;
      char accessKey[8];
      bool deviceAssociated;
      uint32_t interval;
      uint8_t mode;
      bool co2Enabled;
      bool tempEnabled;
      bool humidityEnabled;
      bool lightEnabled;
      bool pressureEnabled;
      bool soundEnabled;
      bool accelEnabled;
      bool gyroEnabled;
      bool ledEnabled;
    };

    struct synapseWearSettings_t settings;
    uint32_t nextUpdate = 0;
    uint32_t interval = DEFAULT_INTERVAL;
    char sendBuf[256] = {0};
    uint8_t sendBufCount = 0;
    uint8_t sendBufOffset = 0;
    uint8_t sendBufToSend = 0;
    uint8_t sendBufSendCount = 0;
    bool bleSetup = false;
    bool bleConnected = false;
    bool dataReady = false;
    bool timeToSleep = false;
    bool bleAuthenticated = false;
    uint32_t dataFrame = 0;
    uint32_t dataLastSentTime = 0;
    uint8_t lastBleCommandReceived = 0;
    uint32_t dataPrepStartTime = 0;
    synapseWearSettings_t *p = (synapseWearSettings_t*)ADDRESS_OF_PAGE(SYNAPSEWEAR_SETTINGS_FLASH);

};

#endif


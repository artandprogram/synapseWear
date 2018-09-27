/*
  Library for synapseWear
  Created by Alexander Reeder, 2017 Apr 1
  For license and other information refer to https://github.com/artandprogram/synapseWear
*/

#include <SimbleeBLE.h>
#include <ota_bootloader.h>
#include "synapseWear.h"

void SYNAPSEWEAR::begin()
{
  //pingI2C();

  if (p->initialized != SYNAPSEWEAR_INITIALIZED_VALUE) {
    Serial.println("synapseWear has been reset, initializing");
    settings = {  SYNAPSEWEAR_INITIALIZED_VALUE, {0}, false, DEFAULT_INTERVAL, MODE_NORMAL, true, true, true, true, true, true, true, true, true };
    saveFirmwareSettings();
  }
  else {
    settings.initialized = p->initialized;
    for (int i = 0; i < 8; i++) {
      settings.accessKey[i] = p->accessKey[i];
    }
    settings.deviceAssociated = p->deviceAssociated;
    settings.interval = p->interval;
    settings.mode = p->mode;
    settings.co2Enabled = p->co2Enabled;
    settings.tempEnabled = p->tempEnabled;
    settings.humidityEnabled = p->humidityEnabled;
    settings.lightEnabled = p->lightEnabled;
    settings.pressureEnabled = p->pressureEnabled;
    settings.soundEnabled = p->soundEnabled;
    settings.accelEnabled = p->accelEnabled;
    settings.gyroEnabled = p->gyroEnabled;
    settings.ledEnabled = p->ledEnabled;
  }
  settings = *p;

  apds9250.begin();
  if (!bm1383aglv.begin())
    lps25h.begin();
  ccs811.begin();
  ens210.begin();
  icm20948.begin();
  max17048.begin();
  sph1642ht5h.begin();
  tca6507.begin();

  delay(50);

  SimbleeBLE.customUUID = "fdef";
  SimbleeBLE.txPowerLevel = -8; // -20 to +4 dBm
  SimbleeBLE.advertisementData = deviceName;
  SimbleeBLE.begin();
  bleSetup = true;
  Serial.println("bleSetup");

  timeToSleep = true;
}

void SYNAPSEWEAR::update()
{

  if (bleAuthenticated) {
    if (millis() > nextUpdate) {
      dataPrepStartTime = millis();
      apds9250.update();

      if (lps25h.isConnected) {
        lps25h.update();
      }
      else {
        bm1383aglv.update();
      }
      ccs811.update();
      ens210.update();
      icm20948.update();
      max17048.update();
      nextUpdate = millis() + settings.interval;

      bleDataPrep();
      bleDataUint16(ccs811.geteCO2());
      bleDataCopy(icm20948.getAccelGyroBuffer(), 12);
      bleDataUint16(apds9250.raw_als);
      bleDataFloatUint8(ens210.celsius);
      bleDataUint8(ens210.percentageH);
      if (lps25h.isConnected) {
        bleDataFloatUint16(lps25h.pressure);
      }
      else {
        bleDataFloatUint16(bm1383aglv.pressure);
      }
      bleDataUint16(ccs811.getTVOC());
      bleDataCopy(max17048.getDataBuffer(), 4);
      bleDataUint16(sph1642ht5h.getSoundLevel());
      bleDataDone();
      //Serial.println("Sending");
    }

    bleUpdate();
  }

  if (sph1642ht5h.isEnabled)
    sph1642ht5h.update();

  tca6507.update();

  if (settings.interval >= 1000 && timeToSleep && millis() > (nextUpdate - 1000)) {
    uint32_t sleepTime = 1000;
    //settings.interval - (millis() - dataPrepStartTime);
    //Serial.println("Sleeping");
    Simblee_ULPDelay(sleepTime);
  }
}

void SYNAPSEWEAR::bleUpdate()
{
  if (bleSetup && bleConnected && dataReady && bleAuthenticated) {
    timeToSleep = false;
    char buf[20] = {0};
    if (sendBufCount > 20) {
      if (sendBufToSend > 20) {
        memcpy(buf, sendBuf + sendBufOffset, 20);
        sendBufOffset += 20;
        sendBufToSend -= 20;
        sendBufSendCount = 20;
      }
      else {
        memcpy(buf, sendBuf + sendBufOffset, sendBufToSend);
        sendBufSendCount = sendBufToSend;
        dataReady = false;
        timeToSleep = true;
      }
    }
    else {
      memcpy(buf, sendBuf, sendBufCount);
      sendBufSendCount = sendBufCount;
      dataReady = false;
      timeToSleep = true;
    }
    bool ret = SimbleeBLE.send(buf, sendBufSendCount);
    if (ret == false) {
      dataReady = false;
      return;
    }
  }
}

void SYNAPSEWEAR::bleDataCopy(uint8_t *data, uint8_t count)
{
  if ((sendBufCount + count) >= sizeof(sendBuf))
    return;

  for (uint8_t i = 0; i < count; i++) {
    sendBuf[sendBufCount] = *(data + i);
    sendBufCount++;
  }
}

void SYNAPSEWEAR::bleDataUint8(uint8_t data)
{
  if ((sendBufCount + 1) >= sizeof(sendBuf))
    return;

  sendBuf[sendBufCount] = data;
  sendBufCount++;
}

void SYNAPSEWEAR::bleDataUint16(uint16_t data)
{
  if ((sendBufCount + 2) >= sizeof(sendBuf))
    return;

  sendBuf[sendBufCount] = (data >> 8) & 0xFF;
  sendBufCount++;
  sendBuf[sendBufCount] = data & 0x0FF;
  sendBufCount++;
}

void SYNAPSEWEAR::bleDataFloatUint8(float data)
{
  if ((sendBufCount + 2) >= sizeof(sendBuf))
    return;

  double fractpart, intpart;
  fractpart = modf(data, &intpart); // *** need to handle +/- for temp
  sendBuf[sendBufCount] = intpart;
  sendBufCount++;
  sendBuf[sendBufCount] = (int)(fractpart * 100);
  sendBufCount++;
}

void SYNAPSEWEAR::bleDataFloatUint16(float data)
{
  if ((sendBufCount + 3) >= sizeof(sendBuf))
    return;

  double fractpart, intpart;
  fractpart = modf(data, &intpart);
  sendBuf[sendBufCount] = ((int)intpart >> 8) & 0XFF;
  sendBufCount++;
  sendBuf[sendBufCount] = (int)intpart & 0XFF;
  sendBufCount++;
  sendBuf[sendBufCount] = (int)(fractpart * 100);
  sendBufCount++;
}

void SYNAPSEWEAR::bleDataPrep()
{
  sendBufCount = sendBufOffset = sendBufToSend = sendBufSendCount = 0;
  sendBuf[0] = 0x00; // header
  sendBuf[1] = 0xff; // header
  sendBuf[2] = 0x00; // total size
  sendBuf[3] = 0x02; // sensor data
  sendBufCount = 4;
}

void SYNAPSEWEAR::bleDataDone()
{
  sendBuf[sendBufCount] = 0x00; // footer
  sendBufCount++;
  sendBuf[sendBufCount] = 0xff;
  sendBufCount++;

  sendBuf[2] = sendBufCount;
  dataReady = true;
  sendBufToSend = sendBufCount;
  dataFrame++;
}

void SYNAPSEWEAR::bleShowData()
{
  for (int i = 0; i < sendBufCount; i++) {
    if (sendBuf[i] < 10)
      Serial.print("0");
    Serial.print(sendBuf[i], HEX);
  }
  Serial.println("");
}

void SYNAPSEWEAR::bleOnConnect()
{
  bleConnected = true;
  bleAuthenticated = false;
  enableSensors();
  tca6507.ping();
}

void SYNAPSEWEAR::bleOnDisconnect()
{
  bleConnected = dataReady = bleAuthenticated = false;
  // don't turn off charging led if led is enabled
  disableSensors();
}

void SYNAPSEWEAR::bleOnReceive(char *data, int count)
{
  if (count == 0)
    return;

  switch (data[0]) {
    case 0x00:
      {
        if (lastBleCommandReceived == 0x10) {
          settings.deviceAssociated = true;
          saveFirmwareSettings();
        }
      }
      break;

    case 0x02:
      {
        validateAccessKey(data, count);
      }
      break;

    case 0x03:
      {
        if (validateAccessKey(data, count)) {
          bleAuthenticated = false;
        }
      }
      break;

    case 0x04:
      {
        if (count < 5) {
          char buf[1];
          buf[0] = 0x01;
          SimbleeBLE.send(buf, 1);
          break;
        }
        settings.interval = (data[1] << 24) + (data[2] << 16) + (data[3] << 8) + data[4];
        char buf[1];
        buf[0] = 0x00;
        SimbleeBLE.send(buf, 1);
        nextUpdate = 0;
        if (count == 6) {
          if (settings.mode != data[5]) {
            settings.mode = data[5];
            if (settings.mode == MODE_LIVE) {
              ccs811.live();
            }
            else {
              ccs811.lowPower();
            }
          }
        }
        saveFirmwareSettings();
      }
      break;

    case 0x05:
      {
        if (count != 10) {
          char buf[1];
          buf[0] = 0x01;
          SimbleeBLE.send(buf, 1);
          break;
        }
        if (data[1] == 0x00) {
          settings.co2Enabled = false;
        }
        else {
          settings.co2Enabled = true;
        }
        if (data[2] == 0x00) {
          settings.tempEnabled = false;
        }
        else {
          settings.tempEnabled = true;
        }
        if (data[3] == 0x00) {
          settings.humidityEnabled = false;
        }
        else {
          settings.humidityEnabled = true;
        }
        if (data[4] == 0x00) {
          settings.lightEnabled = false;
        }
        else {
          settings.lightEnabled = true;
        }
        if (data[5] == 0x00) {
          settings.pressureEnabled = false;
        }
        else {
          settings.pressureEnabled = true;
        }
        if (data[6] == 0x00) {
          settings.soundEnabled = false;
        }
        else {
          settings.soundEnabled = true;
        }
        if (data[7] == 0x00) {
          settings.accelEnabled = false;
        }
        else {
          settings.accelEnabled = true;
        }
        if (data[8] == 0x00) {
          settings.gyroEnabled = false;
        }
        else {
          settings.gyroEnabled = true;
        }
        if (data[9] == 0x00) {
          settings.ledEnabled = false;
        }
        else {
          settings.ledEnabled = true;
        }
        saveFirmwareSettings();
        char buf[1];
        buf[0] = 0x00;
        SimbleeBLE.send(buf, 1);
        enableSensors();
      }
      break;

    case 0x06:
      {
        char buf[7] = {0};
        buf[0] = 0x00;
        buf[1] = FIRMWARE_VERSION_MAJOR;
        buf[2] = FIRMWARE_VERSION_MINOR;
        buf[3] = (FIRMWARE_DATE >> 24) & 0xFFFFFF;
        buf[4] = (FIRMWARE_DATE >> 16) & 0xFFFF;
        buf[5] = (FIRMWARE_DATE >> 8) & 0xFF;
        buf[6] = FIRMWARE_DATE;

        SimbleeBLE.send(buf, 7);
      }
      break;

    case 0x10:
      {
        if (settings.deviceAssociated == false) {
          char buf[9] = {0};
          buf[0] = 0x00;
          for (int i = 1; i <= 8; i++) {
            buf[i] = random(0, 256);
            settings.accessKey[(i - 1)] = buf[i];
          }
          SimbleeBLE.send(buf, 9);
        }
        else {
          char buf[1];
          buf[0] = 0x01;
          SimbleeBLE.send(buf, 1);
        }
      }
      break;

    case 0x11:
      {
        if (lastBleCommandReceived == 0xfe) {
          bleConnected = dataReady = false;
          SimbleeBLE.end();
          ota_bootloader_start();
        }
      }
      break;

    case 0x12:
      {
        if (data[1] == 0x01) {
          settings.deviceAssociated = false;
          for (int i = 1; i <= 8; i++) {
            settings.accessKey[(i - 1)] = 0x00;
          }
          saveFirmwareSettings();
          bleAuthenticated = false;
        }
      }
      break;

    case 0x13:
      {
        tca6507.ping();
      }
      break;

    case 0xfe:
      {
        if (validateAccessKey(data, count)) {
          bleConnected = dataReady = false;
          SimbleeBLE.end();
          ota_bootloader_start();
        }
      }
      break;

    default:
      break;
  }

  lastBleCommandReceived = data[0];
}

void SYNAPSEWEAR::saveFirmwareSettings()
{
  int rc = flashPageErase(PAGE_FROM_ADDRESS(p));
  if (rc != 0) {
    Serial.print("flashPageErase error: ");
    Serial.println(rc);
  }
  rc = flashWriteBlock(p, &settings, sizeof(settings));
  if (rc != 0) {
    Serial.print("flashWriteBlock error: ");
    Serial.println(rc);
  }
}

bool SYNAPSEWEAR::validateAccessKey(char *data, uint8_t count)
{
  bool ok = true;
  if (count == 9) {
    for (int i = 1; i <= 8; i++) {
      if (data[i] != settings.accessKey[(i - 1)])
        ok = false;
    }
  }
  else {
    ok = false;
  }

  char buf[1];
  if (ok) {
    Serial.println("Authenticated");
    bleAuthenticated = true;
    nextUpdate = millis() + 200;
    buf[0] = 0x00;
  }
  else {
    Serial.println("Authentication failed");
    bleAuthenticated = false;
    buf[0] = 0x01;
  }
  SimbleeBLE.send(buf, 1);
}

void SYNAPSEWEAR::enableSensors()
{
  max17048.enable();

  if (settings.co2Enabled) {
    ccs811.enable(settings.mode);
  }
  else {
    ccs811.disable();
  }
  if (settings.tempEnabled || settings.humidityEnabled) {
    ens210.enable();
  }
  else {
    ens210.disable();
  }
  if (settings.lightEnabled) {
    apds9250.enable();
  }
  else {
    apds9250.disable();
  }
  if (settings.pressureEnabled) {
    if (lps25h.isConnected) {
      lps25h.enable();
    }
    else {
      bm1383aglv.enable();
    }
  }
  else {
    if (lps25h.isConnected) {
      lps25h.disable();
    }
    else {
      bm1383aglv.disable();
    }
  }
  if (settings.soundEnabled) {
    sph1642ht5h.enable();
  }
  else {
    sph1642ht5h.disable();
  }
  if (settings.accelEnabled || settings.gyroEnabled) {
    icm20948.enable();
  }
  else {
    icm20948.disable();
  }
  if (settings.ledEnabled) {
    tca6507.enable();
  }
  else {
    tca6507.disable();
  }
}

void SYNAPSEWEAR::disableSensors()
{
  max17048.disable();
  ccs811.disable();
  ens210.disable();
  apds9250.disable();
  if (lps25h.isConnected) {
    lps25h.disable();
  }
  else {
    bm1383aglv.disable();
  }
  sph1642ht5h.disable();
  icm20948.disable();
  tca6507.disable();
}

void SYNAPSEWEAR::beginCharging()
{
  tca6507.beginCharging();
}

void SYNAPSEWEAR::endCharging()
{
  tca6507.endCharging();
}

void SYNAPSEWEAR::pingI2C()
{
  uint8_t buf[1];
  for (uint8_t i = 0; i < 0x77; i++) {
    if (i == 90)
      digitalWrite(PIN_WAKEAIR, LOW);

    uint8_t ret;
    if (i == 90)
      ret = I2Cdev::readByte(i, 0xE0, buf);
    else
      ret = I2Cdev::readByte(i, 0x00, buf);

    if (ret > 0) {
      Serial.print("device found @ 0x");
      Serial.print(i, HEX);
      Serial.print(" 0x");
      Serial.println(buf[0], HEX);
    }

    if (i == 90)
      digitalWrite(PIN_WAKEAIR, HIGH);
  }
}

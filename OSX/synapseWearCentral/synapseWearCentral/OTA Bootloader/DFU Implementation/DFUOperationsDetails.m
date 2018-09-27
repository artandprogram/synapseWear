/*
 * Copyright (c) 2015, Nordic Semiconductor
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the
 * documentation and/or other materials provided with the distribution.
 *
 * 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this
 * software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
 * ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE
 * USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

//#include "DLog.h"

#import "DFUOperationsDetails.h"
#import "Utility.h"
#import "IntelHex2BinConverter.h"

@implementation DFUOperationsDetails


-(void)enableNotification
{
    NSLog(@"DFUOperationsdetails enableNotification");
    [self.bluetoothPeripheral setNotifyValue:YES
                           forCharacteristic:self.dfuControlPointCharacteristic];
}

-(void)startDFU:(DfuFirmwareTypes)firmwareType
{
    NSLog(@"DFUOperationsdetails startDFU");
    self.dfuFirmwareType = firmwareType;
    uint8_t value[] = {START_DFU_REQUEST, firmwareType};
    [self.bluetoothPeripheral writeValue:[NSData dataWithBytes:&value length:sizeof(value)]
                       forCharacteristic:self.dfuControlPointCharacteristic
                                    type:CBCharacteristicWriteWithResponse];
}

-(void)startOldDFU
{
    NSLog(@"DFUOperationsdetails startOldDFU");
    uint8_t value[] = {START_DFU_REQUEST};
    [self.bluetoothPeripheral writeValue:[NSData dataWithBytes:&value length:sizeof(value)]
                       forCharacteristic:self.dfuControlPointCharacteristic
                                    type:CBCharacteristicWriteWithResponse];
}

-(void)writeFileSize:(uint32_t)firmwareSize
{
    NSLog(@"DFUOperationsdetails writeFileSize");
    uint32_t fileSizeCollection[3];
    switch (self.dfuFirmwareType) {
        case SOFTDEVICE:
            fileSizeCollection[0] = firmwareSize;
            fileSizeCollection[1] = 0;
            fileSizeCollection[2] = 0;
            break;
        case BOOTLOADER:
            fileSizeCollection[0] = 0;
            fileSizeCollection[1] = firmwareSize;
            fileSizeCollection[2] = 0;
            break;
        case APPLICATION:
            fileSizeCollection[0] = 0;
            fileSizeCollection[1] = 0;
            fileSizeCollection[2] = firmwareSize;
            break;
            
        default:
            break;
    }
    [self.bluetoothPeripheral writeValue:[NSData dataWithBytes:&fileSizeCollection length:sizeof(fileSizeCollection)]
                       forCharacteristic:self.dfuPacketCharacteristic
                                    type:CBCharacteristicWriteWithoutResponse];
}

-(void)writeFilesSizes:(uint32_t)softdeviceSize
        bootloaderSize:(uint32_t)bootloaderSize
{
    NSLog(@"DFUOperationsdetails writeFilesSizes bootloaderSize");
    uint32_t fileSizeCollection[3];
    fileSizeCollection[0] = softdeviceSize;
    fileSizeCollection[1] = bootloaderSize;
    fileSizeCollection[2] = 0;
    [self.bluetoothPeripheral writeValue:[NSData dataWithBytes:&fileSizeCollection length:sizeof(fileSizeCollection)]
                       forCharacteristic:self.dfuPacketCharacteristic
                                    type:CBCharacteristicWriteWithoutResponse];
}

-(void)writeFileSizeForOldDFU:(uint32_t)firmwareSize
{
    [self.bluetoothPeripheral writeValue:[NSData dataWithBytes:&firmwareSize length:sizeof(firmwareSize)]
                       forCharacteristic:self.dfuPacketCharacteristic
                                    type:CBCharacteristicWriteWithoutResponse];
}

//Init Packet is included in new DFU in SDK 7.0
-(void)sendInitPacket:(NSURL *)metaDataURL
{
    NSData *fileData = [NSData dataWithContentsOfURL:metaDataURL];
    NSLog(@"DFUOperationsdetails sendInitPacket metaDataFile length: %lu",(unsigned long)[fileData length]);

    //send initPacket with parameter value set to Receive Init Packet [0] to dfu Control Point Characteristic
    uint8_t initPacketStart[] = {INITIALIZE_DFU_PARAMETERS_REQUEST, START_INIT_PACKET};
    [self.bluetoothPeripheral writeValue:[NSData dataWithBytes:&initPacketStart length:sizeof(initPacketStart)]
                       forCharacteristic:self.dfuControlPointCharacteristic
                                    type:CBCharacteristicWriteWithResponse];

    //send init Packet data to dfu Packet Characteristic
    [self.bluetoothPeripheral writeValue:fileData
                       forCharacteristic:self.dfuPacketCharacteristic
                                    type:CBCharacteristicWriteWithoutResponse];

    //send initPacket with parameter value set to Init Packet Complete [1] to dfu Control Point Characteristic
    uint8_t initPacketEnd[] = {INITIALIZE_DFU_PARAMETERS_REQUEST, END_INIT_PACKET};
    [self.bluetoothPeripheral writeValue:[NSData dataWithBytes:&initPacketEnd length:sizeof(initPacketEnd)]
                       forCharacteristic:self.dfuControlPointCharacteristic
                                    type:CBCharacteristicWriteWithResponse];
}

-(void)buildAndSendInitPacket:(uint16_t)crc16BinFileData
{
    // see /nRF51_SDK_8.0.0_5fc2c3a/documentation/s110/html/a00093.html
    uint16_t initPacket[] =
    {
        0xffff,              // device type
        0xffff,              // device revision
        0xffff,              // application revision (upper)
        0xffff,              // application revision (lower)
        0x0001,              // softdevice firmware id count
        0x0064,              // s110 v8.0.0
        crc16BinFileData,    // CRC-16-CCITT for image to transfer
    };

    //send initPacket with parameter value set to Receive Init Packet [0] to dfu Control Point Characteristic
    uint8_t initPacketStart[] = {INITIALIZE_DFU_PARAMETERS_REQUEST, START_INIT_PACKET};
    [self.bluetoothPeripheral writeValue:[NSData dataWithBytes:&initPacketStart length:sizeof(initPacketStart)]
                       forCharacteristic:self.dfuControlPointCharacteristic
                                    type:CBCharacteristicWriteWithResponse];

    //send init Packet data to dfu Packet Characteristic
    [self.bluetoothPeripheral writeValue:[NSData dataWithBytes:&initPacket length:sizeof(initPacket)]
                       forCharacteristic:self.dfuPacketCharacteristic
                                    type:CBCharacteristicWriteWithoutResponse];

    //send initPacket with parameter value set to Init Packet Complete [1] to dfu Control Point Characteristic
    uint8_t initPacketEnd[] = {INITIALIZE_DFU_PARAMETERS_REQUEST, END_INIT_PACKET};
    [self.bluetoothPeripheral writeValue:[NSData dataWithBytes:&initPacketEnd length:sizeof(initPacketEnd)]
                       forCharacteristic:self.dfuControlPointCharacteristic
                                    type:CBCharacteristicWriteWithResponse];
}

-(void)resetAppToDFUMode
{
    [self.bluetoothPeripheral setNotifyValue:YES forCharacteristic:self.dfuControlPointCharacteristic];
    uint8_t value[] = {START_DFU_REQUEST, APPLICATION};
    [self.bluetoothPeripheral writeValue:[NSData dataWithBytes:&value length:sizeof(value)]
                       forCharacteristic:self.dfuControlPointCharacteristic
                                    type:CBCharacteristicWriteWithResponse];
}

//dfu Version characteristic is introduced in SDK 7.0
-(void)getDfuVersion
{
    NSLog(@"DFUOperationsdetails getDFUVersion");
    [self.bluetoothPeripheral readValueForCharacteristic:self.dfuVersionCharacteristic];
}

-(void)enablePacketNotification
{
    NSLog(@"DFUOperationsdetails enablePacketNotification");
    uint8_t value[] = {PACKET_RECEIPT_NOTIFICATION_REQUEST, PACKETS_NOTIFICATION_INTERVAL,0};
    [self.bluetoothPeripheral writeValue:[NSData dataWithBytes:&value length:sizeof(value)]
                       forCharacteristic:self.dfuControlPointCharacteristic
                                    type:CBCharacteristicWriteWithResponse];
}

-(void)receiveFirmwareImage
{
    NSLog(@"DFUOperationsdetails receiveFirmwareImage");
    uint8_t value = RECEIVE_FIRMWARE_IMAGE_REQUEST;
    [self.bluetoothPeripheral writeValue:[NSData dataWithBytes:&value length:sizeof(value)]
                       forCharacteristic:self.dfuControlPointCharacteristic
                                    type:CBCharacteristicWriteWithResponse];
}

-(void) validateFirmware
{
    NSLog(@"DFUOperationsdetails validateFirmwareImage");
    uint8_t value = VALIDATE_FIRMWARE_REQUEST;
    [self.bluetoothPeripheral writeValue:[NSData dataWithBytes:&value length:sizeof(value)]
                       forCharacteristic:self.dfuControlPointCharacteristic
                                    type:CBCharacteristicWriteWithResponse];
}

-(void)activateAndReset
{
    NSLog(@"DFUOperationsdetails activateAndReset");
    uint8_t value = ACTIVATE_AND_RESET_REQUEST;
    [self.bluetoothPeripheral writeValue:[NSData dataWithBytes:&value length:sizeof(value)]
                       forCharacteristic:self.dfuControlPointCharacteristic
                                    type:CBCharacteristicWriteWithResponse];
}

-(void)resetSystem
{
    NSLog(@"DFUOperationsDetails resetSystem");
    uint8_t value = RESET_SYSTEM;
    [self.bluetoothPeripheral writeValue:[NSData dataWithBytes:&value length:sizeof(value)]
                       forCharacteristic:self.dfuControlPointCharacteristic
                                    type:CBCharacteristicWriteWithResponse];
}

-(void)setPeripheralAndOtherParameters:(CBPeripheral *)peripheral
            controlPointCharacteristic:(CBCharacteristic *)controlPointCharacteristic
                  packetCharacteristic:(CBCharacteristic *)packetCharacteristic
{
    NSLog(@"DFUOperationsdetails setPeripheralAndOtherParameters: %@", [[peripheral identifier] UUIDString]);
    self.bluetoothPeripheral = peripheral;
    self.dfuControlPointCharacteristic = controlPointCharacteristic;
    self.dfuPacketCharacteristic = packetCharacteristic;
}

-(void)setPeripheralAndOtherParametersWithVersion:(CBPeripheral *)peripheral
                       controlPointCharacteristic:(CBCharacteristic *)controlPointCharacteristic
                             packetCharacteristic:(CBCharacteristic *)packetCharacteristic
                            versionCharacteristic:(CBCharacteristic *)versionCharacteristic
{
    NSLog(@"DFUOperationsdetails setPeripheralAndOtherParametersWithVersion: %@", [[peripheral identifier] UUIDString]);
    self.bluetoothPeripheral = peripheral;
    self.dfuControlPointCharacteristic = controlPointCharacteristic;
    self.dfuPacketCharacteristic = packetCharacteristic;
    self.dfuVersionCharacteristic = versionCharacteristic;
}

/*
-(void)MQDumpNSData:(NSData *)data
{
    const unsigned char *ptr = [data bytes];
    //unsigned char s[512];
    NSString *str = @"";
    for(int i = 0, n = (int)[data length]; i < n; ++i)
    {
        unsigned char c = *ptr++;
        //s[i] = c;
        //NSLog(@"char=%c hex=%x", c, c);
        str = [str stringByAppendingString:[NSString stringWithFormat:@"%.2hhx", c]];
    }
    NSLog(@"MQDumpNSData: %@", str);
}*/

@end

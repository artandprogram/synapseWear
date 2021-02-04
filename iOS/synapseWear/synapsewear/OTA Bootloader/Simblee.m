/*
 * Copyright (c) 2015 RF Digital Corp. All Rights Reserved.
 *
 * The source code contained in this file and all intellectual property embodied in
 * or covering the source code is the property of RF Digital Corp. or its licensors.
 * Your right to use this source code and intellectual property is non-transferable,
 * non-sub licensable, revocable, and subject to terms and conditions of the
 * SIMBLEE SOFTWARE LICENSE AGREEMENT.
 * http://www.simblee.com/licenses/SimbleeSoftwareLicenseAgreement.txt
 *
 * THE SOURCE CODE IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND.
 *
 * This heading must NOT be removed from this file.
 */

//#include "DLog.h"

#import "Simblee.h"

#import "SimbleeManager.h"

@interface Simblee()
{
    NSTimer *connectTimer;
    
    CBUUID *service_uuid;
    CBUUID *send_uuid;
    CBUUID *receive_uuid;
    CBUUID *signal_uuid;
    
    CBCharacteristic *send_characteristic;
    CBCharacteristic *receive_characteristic;
    CBCharacteristic *signal_characteristic;
}
@end

@implementation Simblee

- (id)init
{
    //DLog();
    
    self = [super init];
    if (self) {
        _connectInterval = 3.0;
    }
    
    return self;
}

- (char)nextHex:(char)ch
{
    ch = tolower(ch);
    if (ch == '9')
        return 'a';
    if (ch == 'f')
        return '0';
    return ch + 1;
}

- (NSString*)incrementUUID:(CBUUID*)uuid
                    amount:(uint8_t)amount
{
    NSString *uuidString = [uuid UUIDString];
    NSData *data = [uuidString dataUsingEncoding:NSUTF8StringEncoding];
    char *bytes = (char *)[data bytes];
    NSInteger len = [data length];
    int pos = (len > 4 ? 7 : 3);  // 7 for 128 uuid, 1 for 16 bit uuid
    while (amount-- > 0) {
        bytes[pos] = [self nextHex:bytes[pos]];
        if (bytes[pos] == '0')
            bytes[pos-1] = [self nextHex:bytes[pos-1]];
    }
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}
/*
#pragma mark - forwarded CBCentralManagerDelegate methods

// suppress warning, required by protocol, never used
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
}

- (void)centralManager:(CBCentralManager *)central
 didDiscoverPeripheral:(CBPeripheral *)peripheral
     advertisementData:(NSDictionary *)advertisementData
                  RSSI:(NSNumber *)RSSI
{
    NSLog(@"CBCentralManager didDiscoverPeripheral: %@ advertisementData: %@ RSSI: %@", peripheral, advertisementData, RSSI);
    
    if ([_delegate respondsToSelector:@selector(didDiscoverSimblee:)]) {
        [_delegate didDiscoverSimblee:self];
    } else if ([_delegate respondsToSelector:@selector(didDiscover)]) {
        [_delegate didDiscover];
    }
}

- (void)centralManager:(CBCentralManager *)central
  didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"CBCentralManager didConnectPeripheral: %@", peripheral);

    [peripheral discoverServices:_connectServices];
}

- (void)centralManager:(CBCentralManager *)central
didFailToConnectPeripheral:(CBPeripheral *)peripheral
                 error:(NSError *)error
{
    NSLog(@"CBCentralManager didFailToConnectPeripheral: %@ error: %@", peripheral, error);

    if (_state == SimbleeStateConnecting) {
        NSLog(@"*** retrying connect **");
        [central connectPeripheral:peripheral options:nil];
    }
}

- (void)centralManager:(CBCentralManager *)central
didDisconnectPeripheral:(CBPeripheral *)peripheral
                 error:(NSError *)error
{
    NSLog(@"CBCentralManager didDisconnectPeripheral: %@ error: %@", peripheral, error);

    // disconnect requested
    if (_state == SimbleeStateDisconnecting) {
        _state = SimbleeStateDisconnected;
        if ([_delegate respondsToSelector:@selector(didDisconnectSimblee:)]) {
            [_delegate didDisconnectSimblee:self];
        } else if ([_delegate respondsToSelector:@selector(didDisconnect)]) {
            [_delegate didDisconnect];
        }
        return;
    }
    
    // retry connect
    if (_state == SimbleeStateConnecting) {
        NSLog(@"*** retrying connect **");
        [central connectPeripheral:peripheral options:nil];
        return;
    }

    if ([_delegate respondsToSelector:@selector(didLooseConnectSimblee:)]) {
        [_delegate didLooseConnectSimblee:self];
    } else if ([_delegate respondsToSelector:@selector(didLooseConnect)]) {
        [_delegate didLooseConnect];
    }
}
 */
#pragma mark - CBPeripheralDelegate methods

- (void)peripheral:(CBPeripheral *)peripheral
didDiscoverServices:(NSError *)error
{
    NSLog(@"Simblee didDiscoverServices: %@", [[peripheral identifier] UUIDString]);
    if (error) {
        NSLog(@"Error: %@", [error localizedDescription]);
    }

    for (CBService *service in peripheral.services) {
        if (! service_uuid) {
            service_uuid = service.UUID;

            CBUUID *char_uuid = NULL;
            CBUUID *base_uuid = [CBUUID UUIDWithString:@"2d30c081-f39f-4ce6-923f-3484ea480596"];
            if ([service_uuid isEqual:[CBUUID UUIDWithString:@"2220"]]) {
                // original uuid (16-bit service with 16-bit characteristics)
                char_uuid = service_uuid;
            } else if ([service_uuid.data length] == 2) {
                // 16-bit service with 128-bit characteristics
                char_uuid = base_uuid;
            } else {
                // 128-bit service with 128-bit characteristics
                char_uuid = service_uuid;
            }

            receive_uuid = [CBUUID UUIDWithString:[self incrementUUID:char_uuid amount:1]];
            send_uuid = [CBUUID UUIDWithString:[self incrementUUID:char_uuid amount:2]];
            signal_uuid = [CBUUID UUIDWithString:[self incrementUUID:char_uuid amount:3]];
            
            _connectedService = service.UUID;
            
            [peripheral discoverCharacteristics:@[receive_uuid, send_uuid, signal_uuid] forService:service];
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral
didDiscoverCharacteristicsForService:(CBService *)service
             error:(NSError *)error
{
    //NSLog(@"Simblee didDiscoverCharacteristicsForService: %@ error: %@", service, error);
    NSLog(@"Simblee didDiscoverCharacteristicsForService: %@", [[peripheral identifier] UUIDString]);
    if (error) {
        NSLog(@"Error: %@", [error localizedDescription]);
    }

    for (CBService *service in peripheral.services) {
        if ([service.UUID isEqual:service_uuid]) {
            for (CBCharacteristic *characteristic in service.characteristics) {
                if ([characteristic.UUID isEqual:receive_uuid]) {
                    receive_characteristic = characteristic;
                    [peripheral setNotifyValue:YES forCharacteristic:characteristic];
                } else if ([characteristic.UUID isEqual:send_uuid]) {
                    send_characteristic = characteristic;
                } else if ([characteristic.UUID isEqual:signal_uuid]) {
                    signal_characteristic = characteristic;
                }
            }
            
            _state = SimbleeStateConnected;
            
            if (connectTimer) {
                [connectTimer invalidate];
                connectTimer = nil;
            }
            
            if ([_delegate respondsToSelector:@selector(didConnectSimblee:)]) {
                [_delegate didConnectSimblee:self];
            } else if ([_delegate respondsToSelector:@selector(didConnect)]) {
                [_delegate didConnect];
            }
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral
didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic
             error:(NSError *)error
{
    //NSLog(@"Simblee didUpdateValueForCharacteristic: %@ error: %@", characteristic, error);
    NSLog(@"Simblee didUpdateValueForCharacteristic: %@", [[peripheral identifier] UUIDString]);
    if (error) {
        NSLog(@"Error: %@", [error localizedDescription]);
    }

    if ([characteristic.UUID isEqual:receive_uuid]) {
        if ([_delegate respondsToSelector:@selector(didReceive:)]) {
            [_delegate didReceive:characteristic.value];
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral
didWriteValueForCharacteristic:(CBCharacteristic *)characteristic
             error:(NSError *)error
{
    //NSLog(@"Simblee didWriteValueForCharacteristic: %@ error: %@", characteristic, error);
    NSLog(@"Simblee didWriteValueForCharacteristic: %@", [[peripheral identifier] UUIDString]);
    if (error) {
        NSLog(@"Error: %@", [error localizedDescription]);
    }
}

#pragma mark - Simblee methods

- (void)restoreState
{
    NSLog(@"Simblee restoreState");

    // note: services/characteristics are not restored to deliver didDisconnect:
    
    _state = SimbleeStateDisconnected;
    if (_peripheral.state == CBPeripheralStateConnecting) {
        _state = SimbleeStateConnecting;
    } else if (_peripheral.state == CBPeripheralStateConnected) {
        _state = SimbleeStateConnected;
    }
    
    for (CBService *service in _peripheral.services) {
        if (! service_uuid) {
            service_uuid = service.UUID;

            CBUUID *char_uuid = NULL;
            CBUUID *base_uuid = [CBUUID UUIDWithString:@"2d30c081-f39f-4ce6-923f-3484ea480596"];
            if ([service_uuid isEqual:[CBUUID UUIDWithString:@"2220"]]) {
                // original uuid (16-bit service with 16-bit characteristics)
                char_uuid = service_uuid;
            } else if ([service_uuid.data length] == 2) {
                // 16-bit service with 128-bit characteristics
                char_uuid = base_uuid;
            } else {
                // 128-bit service with 128-bit characteristics
                char_uuid = service_uuid;
            }
            
            receive_uuid = [CBUUID UUIDWithString:[self incrementUUID:char_uuid amount:1]];
            send_uuid = [CBUUID UUIDWithString:[self incrementUUID:char_uuid amount:2]];
            signal_uuid = [CBUUID UUIDWithString:[self incrementUUID:char_uuid amount:3]];
            
            _connectedService = service.UUID;
            
            if (service.characteristics) {
                for (CBCharacteristic *characteristic in service.characteristics) {
                    if ([characteristic.UUID isEqual:receive_uuid]) {
                        receive_characteristic = characteristic;
                        // [peripheral setNotifyValue:YES forCharacteristic:characteristic];
                    } else if ([characteristic.UUID isEqual:send_uuid]) {
                        send_characteristic = characteristic;
                    } else if ([characteristic.UUID isEqual:signal_uuid]) {
                        signal_characteristic = characteristic;
                    }
                }
            }
        }
    }
}

- (void)connect:(NSArray *)services
{
    NSLog(@"Simblee connect: %@", services);

    if (_simbleeManager.central.state != CBManagerStatePoweredOn/*CBCentralManagerStatePoweredOn*/) {
        NSLog(@"delaying connect until ble powered on");
        Simblee *this = self;
        [_simbleeManager addBlePowerOnBlock: ^{ [this connect:services]; } ];
        return;
    }
    
    if (_connectInterval) {
        connectTimer = [NSTimer scheduledTimerWithTimeInterval:_connectInterval
                                                        target:self
                                                      selector:@selector(connectTimeout:)
                                                      userInfo:self
                                                       repeats:NO];
    }

    service_uuid = nil;
    send_uuid = nil;
    receive_uuid = nil;
    signal_uuid = nil;
    
    send_characteristic = nil;
    signal_characteristic = nil;
    
    _connectServices = services;
    
    _state = SimbleeStateConnecting;
    [_simbleeManager.central connectPeripheral:_peripheral options:nil];
}

- (void)connectTimeout:(NSTimer *)timer
{
    NSLog(@"Simblee connectTimeout");

    Simblee *simblee = timer.userInfo;
    
    [simblee disconnect];

    if ([_delegate respondsToSelector:@selector(didNotConnectSimblee:)]) {
        [_delegate didNotConnectSimblee:self];
    } else if ([_delegate respondsToSelector:@selector(didNotConnect)]) {
        [_delegate didNotConnect];
    }
}

- (void)send:(NSData *)data
{
    NSLog(@"Simblee send: %@", data);

    if (_state != SimbleeStateConnected) {
        /*
        @throw [NSException exceptionWithName:@"sendData" reason:@"please wait for state connected" userInfo:nil];
        */
        return;
    }
    
    if ([data length] > MAX_DATA) {
        @throw [NSException exceptionWithName:@"sendData" reason:@"max data size exceeded" userInfo:nil];
    }
    
    [_peripheral writeValue:data forCharacteristic:send_characteristic type:CBCharacteristicWriteWithoutResponse];
}

- (void)signal:(uint8_t)number
          data:(NSData *)data
{
    NSLog(@"Simblee signal: %d %@", number, data);

    if (1 + [data length] > MAX_DATA) {
        @throw [NSException exceptionWithName:@"signal" reason:@"max data size exceeded" userInfo:nil];
    }
    
    if (_state == SimbleeStateConnected) {
        NSLog(@"writing to signal characteristic");
        // iOS SDK 7.0 - at least one byte must now be transferred
        NSMutableData *value = [[NSMutableData alloc] init];
        [value appendBytes:&number length:1];
        [value appendData:data];
        [_peripheral writeValue:value forCharacteristic:signal_characteristic type:CBCharacteristicWriteWithoutResponse];
    }
}

- (void)disconnect
{
    NSLog(@"Simblee disconnect");

    [self signal:SIGNAL_DISCONNECT data:nil];
    
    _state = SimbleeStateDisconnecting;

    if (receive_characteristic != nil) {
      [_peripheral setNotifyValue:NO forCharacteristic:receive_characteristic];
    }
    [_simbleeManager.central cancelPeripheralConnection:_peripheral];
}

@end

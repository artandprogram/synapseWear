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

#import <Foundation/Foundation.h>

#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
#import <CoreBluetooth/CoreBluetooth.h>
#elif TARGET_OS_MAC
#import <IOBluetooth/IOBluetooth.h>
#endif

#import "SimbleeDelegate.h"

@class SimbleeManager;

#define  MAX_DATA  20

// signal numbers 0-15 reserved for use by Simblee
//     1 = Disconnect
// signal numbers 16-31 reserved for use by application
// signal numbers 31-255 reserved for future use
#define  SIGNAL_DISCONNECT  1

typedef enum
{
    SimbleeStateDisconnected = 0,
    SimbleeStateConnecting,
    SimbleeStateConnected,
    SimbleeStateDisconnecting
} SimbleeState;

@interface Simblee : NSObject</*CBCentralManagerDelegate, */CBPeripheralDelegate>
{
}

@property(assign, nonatomic) id<SimbleeDelegate> delegate;

@property(assign, nonatomic) float connectInterval;

@property(assign, nonatomic) uint32_t state;
@property(strong, nonatomic) CBPeripheral *peripheral;

@property(strong, nonatomic) SimbleeManager *simbleeManager;

@property(strong, nonatomic) NSString *name;
@property(strong, nonatomic) NSString *identifier;
@property(strong, nonatomic) NSNumber *RSSI;
@property(strong, nonatomic) NSNumber *txPower;
@property(strong, nonatomic) NSArray *advertisementServices;

@property(strong, nonatomic) NSData *advertisementData;
@property(strong, nonatomic) NSDate *lastAdvertisement;
@property(assign, nonatomic) NSInteger advertisementPackets;

@property(strong, nonatomic) NSMutableArray *sampleRSSI;
@property(strong, nonatomic) NSDate *startRSSI;

@property(strong, nonatomic) NSArray *connectServices;
@property(strong, nonatomic) CBUUID *connectedService;

@property(assign, nonatomic) bool outOfRange;

- (void)restoreState;

- (void)connect:(NSArray *)services;
- (void)send:(NSData *)data;
- (void)signal:(uint8_t)number data:(NSData *)data;
- (void)disconnect;

@end

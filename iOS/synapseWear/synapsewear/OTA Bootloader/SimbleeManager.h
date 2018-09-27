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

@interface SimbleeManager : NSObject <CBCentralManagerDelegate>
{
}

+ (SimbleeManager *)sharedSimbleeManager;

@property(assign, nonatomic) id<SimbleeDelegate> delegate;

@property(strong, nonatomic) NSArray *scanServices;
@property(assign, nonatomic) bool scanUpdates;
@property(assign, nonatomic) float restartInterval;

@property(strong, nonatomic) CBCentralManager *central;
@property(strong, nonatomic) NSMutableArray *simblees;

@property(assign, nonatomic) bool isScanning;

- (void)addBlePowerOnBlock:(void(^)(void))block;

- (Simblee *)simbleeFromPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI;

- (void)startScan;
- (void)stopScan;

@end

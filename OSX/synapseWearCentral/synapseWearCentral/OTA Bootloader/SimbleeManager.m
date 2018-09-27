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

#include <objc/message.h>

//#import "AppDelegate.h"

#import "Simblee.h"
#import "SimbleeManager.h"

@interface SimbleeManager()
{
    //AppDelegate *appDelegate;
    void(^blePowerOnScanBlock)(void);
    NSMutableArray *blePowerOnBlocks;
    NSTimer *restartTimer;
}
@end

@implementation SimbleeManager

+ (SimbleeManager *)sharedSimbleeManager
{
    static SimbleeManager *simbleeManager;
    if (! simbleeManager) {
        simbleeManager = [[SimbleeManager alloc] init];
    }
    return simbleeManager;
}

- (id)init
{
    //DLog();
    
    self = [super init];
    
    if (self) {
        _simblees = [[NSMutableArray alloc] init];
        
        _restartInterval = 60.0;
        
        //appDelegate = [[UIApplication sharedApplication] delegate];
        NSDictionary *options = nil;
        /*if (appDelegate.backgroundMode) {
            options = @{ CBCentralManagerOptionRestoreIdentifierKey :  @"SimbleeManager" };
        }*/
        _central = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:options];
        
        blePowerOnBlocks = [[NSMutableArray alloc] init];
    }
    
    return self;
}

#pragma mark - restart timer

- (void) restartTick:(NSTimer *)timer
{
    // restart scan every 60 seconds to prevent foreground slowdown
    
    [_central stopScan];

    NSDictionary *options = nil;
    if (_scanUpdates) {
        options = @{ CBCentralManagerScanOptionAllowDuplicatesKey : @YES };
    }
    
    [_central scanForPeripheralsWithServices:_scanServices options:options];
}

#pragma mark - misc

- (Simblee *)simbleeForPeripheral:(CBPeripheral *)peripheral
{
    for (Simblee *simblee in _simblees) {
        if ([peripheral isEqual:simblee.peripheral]) {
            return simblee;
        }
    }
    return nil;
}

#pragma mark - CentralManagerDelegate methods

- (void)centralManagerDidUpdateState:(CBCentralManager *)aCentral
{
    NSLog(@"SimbleeManager centralManagerDidUpdateState: %ld", (long)[_central state]);

    switch ([_central state]) {
        case CBManagerStateUnknown:
            break;
            
        case CBManagerStateUnsupported:
            if ([_delegate respondsToSelector:@selector(bleUnsupported)]) {
                [_delegate bleUnsupported];
            }
            //[appDelegate bleUnsupported];
            break;
            
        case CBManagerStateUnauthorized:
            if ([_delegate respondsToSelector:@selector(bleUnauthorized)]) {
                [_delegate bleUnauthorized];
            }
            //[appDelegate bleUnauthorized];
            break;
            
        case CBManagerStatePoweredOff:
            if ([_delegate respondsToSelector:@selector(blePoweredOff)]) {
                [_delegate blePoweredOff];
            }
            //[appDelegate blePoweredOff];
            break;
            
        case CBManagerStatePoweredOn:
            
            if (blePowerOnScanBlock) {
                NSLog(@"ble powered on; executing scan block");
                blePowerOnScanBlock();
                blePowerOnScanBlock = nil;
            }
            
            for (void(^block)(void) in blePowerOnBlocks) {
                NSLog(@"ble powered on; executing block");
                block();
            }
            [blePowerOnBlocks removeAllObjects];
            
            if ([_delegate respondsToSelector:@selector(blePoweredOn)]) {
                [_delegate blePoweredOn];
            }
            //[appDelegate blePoweredOn];
            break;
            
        case CBManagerStateResetting:
            break;
    }
}

- (void)centralManager:(CBCentralManager *)central
didRetrieveConnectedPeripherals:(NSArray *)peripherals
{
    NSLog(@"SimbleeManager didRetrieveConnectedPeripherals: %@", peripherals);
}

- (Simblee *)simbleeFromPeripheral:(CBPeripheral *)peripheral
                 advertisementData:(NSDictionary *)advertisementData
                              RSSI:(NSNumber *)RSSI
{
    NSLog(@"SimbleeManager simbleeFromPeripheral: %@ advertisementData: %@ RSSI: %@", [[peripheral identifier] UUIDString], advertisementData, RSSI);

    // peripheral.name has caching issues
    id localName = [advertisementData objectForKey:CBAdvertisementDataLocalNameKey];
    
    Simblee *simblee = [self simbleeForPeripheral:peripheral];
    if (! simblee) {
        simblee = [[Simblee alloc] init];
        
        simblee.simbleeManager = self;

        simblee.peripheral = peripheral;
        peripheral.delegate = simblee;

        //simblee.delegate = (id<SimbleeDelegate>)appDelegate.scanViewController;
        
        simblee.name = (localName ? localName : peripheral.name);
        
        simblee.identifier = peripheral.identifier.UUIDString;
        
        simblee.RSSI = RSSI;
        
        simblee.sampleRSSI = [[NSMutableArray alloc] init];
        
        [_simblees addObject:simblee];
    }
    
    if (localName) {
        simblee.name = localName;
    }
    
    id txPower = [advertisementData objectForKey:CBAdvertisementDataTxPowerLevelKey];
    if (txPower) {
        simblee.txPower = txPower;
    }
    
    /*
     // not available in ios 8
     id advChannel = [advertisementData objectForKey:@"kCBAdvDataChannel"];
     if (advChannel) {
     simblee.advChannel = advChannel;
     }
     */
    
    id advServices = [advertisementData objectForKey:CBAdvertisementDataServiceUUIDsKey];
    if (advServices) {
        simblee.advertisementServices = advServices;  // NSArray of NSUUIDs ([[advService objectAtIndex:0] UUIDString])
    }
    
    simblee.advertisementData = nil;
    
    id manufacturerData = [advertisementData objectForKey:CBAdvertisementDataManufacturerDataKey];
    if (manufacturerData) {
        const uint8_t *bytes = [manufacturerData bytes];
        NSUInteger len = [manufacturerData length];
        // skip manufacturer uuid
        NSData *data = [NSData dataWithBytes:bytes+2 length:len-2];
        simblee.advertisementData = data;
    }
    
    NSDate *date = [NSDate date];
    
    if (advertisementData) {
        simblee.lastAdvertisement = date;
        simblee.advertisementPackets++;
    }
    
    if (RSSI && _scanUpdates) {
        if (! simblee.startRSSI) {
            simblee.startRSSI = date;
        }
        // not indeterminate rssi sample
        if (RSSI.intValue != 127) {
            [simblee.sampleRSSI addObject:RSSI];
        }
    }
    
    return simblee;
}

- (void)centralManager:(CBCentralManager *)central
 didDiscoverPeripheral:(CBPeripheral *)peripheral
     advertisementData:(NSDictionary *)advertisementData
                  RSSI:(NSNumber *)RSSI
{
    NSLog(@"SimbleeManager didDiscoverPeripheral: %@ advertisementData: %@ RSSI: %@", [[peripheral identifier] UUIDString], advertisementData, RSSI);

    Simblee *simblee = [self simbleeFromPeripheral:peripheral advertisementData:advertisementData RSSI:RSSI];
    if ([_delegate respondsToSelector:@selector(didDiscoverSimblee:)]) {
        [_delegate didDiscoverSimblee:simblee];
    } else if ([_delegate respondsToSelector:@selector(didDiscover)]) {
        [_delegate didDiscover];
    }
    //[simblee centralManager:central didDiscoverPeripheral:peripheral advertisementData:advertisementData RSSI:RSSI];
}

- (void)centralManager:(CBCentralManager *)central
  didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"SimbleeManager didConnectPeripheral: %@", [[peripheral identifier] UUIDString]);

    Simblee *simblee = [self simbleeForPeripheral:peripheral];
    if (simblee) {
        [peripheral discoverServices:simblee.connectServices];
        //[simblee centralManager:central didConnectPeripheral:peripheral];
    }
}

- (void)centralManager:(CBCentralManager *)central
didFailToConnectPeripheral:(CBPeripheral *)peripheral
                 error:(NSError *)error
{
    NSLog(@"SimbleeManager didFailToConnectPeripheral: %@ error: %@", [[peripheral identifier] UUIDString], error);

    Simblee *simblee = [self simbleeForPeripheral:peripheral];
    if (simblee) {
        if (simblee.state == SimbleeStateConnecting) {
            NSLog(@"*** retrying connect **");
            [central connectPeripheral:peripheral options:nil];
        }
        //[simblee centralManager:central didFailToConnectPeripheral:peripheral error:error];
    }
}

- (void)centralManager:(CBCentralManager *)central
didDisconnectPeripheral:(CBPeripheral *)peripheral
                 error:(NSError *)error
{
    NSLog(@"SimbleeManager didDisconnectPeripheral: %@ error: %@", [[peripheral identifier] UUIDString], error);

    Simblee *simblee = [self simbleeForPeripheral:peripheral];
    if (simblee) {
        // disconnect requested
        if (simblee.state == SimbleeStateDisconnecting) {
            simblee.state = SimbleeStateDisconnected;
            if ([_delegate respondsToSelector:@selector(didDisconnectSimblee:)]) {
                [_delegate didDisconnectSimblee:simblee];
            } else if ([_delegate respondsToSelector:@selector(didDisconnect)]) {
                [_delegate didDisconnect];
            }
            return;
        }
        // retry connect
        if (simblee.state == SimbleeStateConnecting) {
            NSLog(@"*** retrying connect **");
            [central connectPeripheral:peripheral options:nil];
            return;
        }
        if ([_delegate respondsToSelector:@selector(didLooseConnectSimblee:)]) {
            [_delegate didLooseConnectSimblee:simblee];
        } else if ([_delegate respondsToSelector:@selector(didLooseConnect)]) {
            [_delegate didLooseConnect];
        }
        //[simblee centralManager:central didDisconnectPeripheral:peripheral error:error];
    }
}

- (void)centralManager:(CBCentralManager *)central
      willRestoreState:(NSDictionary *)dict
{
    NSLog(@"SimbleeManager willRestoreState: %@", dict);

    NSArray *peripherals = dict[CBCentralManagerRestoredStatePeripheralsKey];
    for (CBPeripheral *peripheral in peripherals) {
        Simblee *simblee = [self simbleeFromPeripheral:peripheral advertisementData:nil RSSI:nil];
        [simblee restoreState];
    }
    
    NSArray *services = [dict objectForKey:CBCentralManagerRestoredStateScanServicesKey];
    NSDictionary *options = [dict objectForKey:CBCentralManagerRestoredStateScanOptionsKey];
    if (services) {
        _scanServices = services;
        _scanUpdates = false;
        if (options) {
            id obj = [options objectForKey:CBCentralManagerScanOptionAllowDuplicatesKey];
            if (obj) {
                _scanUpdates = (bool)obj;
            }
        }
        // at ble power on, bluetooth launch will automatically resume scanning
        _isScanning = true;
    }

    //[appDelegate simbleeManager:self restoredState:dict];
}

#pragma mark - SimbleeManager methods

- (void)addBlePowerOnBlock:(void(^)(void))block
{
    //DLog();
    [blePowerOnBlocks addObject:block];
}

- (void)startScan
{
    NSLog(@"SimbleeManager startScan");

    _isScanning = true;

    if (_central.state != CBManagerStatePoweredOn) {
        NSLog(@"delaying startScan until ble powered on");
        SimbleeManager *this = self;
        blePowerOnScanBlock = ^{ [this startScan]; };
        return;
    }

    NSDictionary *options = nil;
    if (_scanUpdates) {
        options = @{ CBCentralManagerScanOptionAllowDuplicatesKey : @YES };
    }

    [_central scanForPeripheralsWithServices:_scanServices options:options];
    
    if (_restartInterval) {
        restartTimer = [NSTimer scheduledTimerWithTimeInterval:_restartInterval
                                                        target:self
                                                      selector:@selector(restartTick:)
                                                      userInfo:nil
                                                       repeats:YES];
    }
}

- (void)stopScan
{
    NSLog(@"SimbleeManager stopScan");

    _isScanning = false;
    
    if (_central.state != CBManagerStatePoweredOn) {
        blePowerOnScanBlock = nil;
        return;
    }
    
    if (restartTimer) {
        [restartTimer invalidate];
        restartTimer = nil;
    }

    [_central stopScan];
}

@end

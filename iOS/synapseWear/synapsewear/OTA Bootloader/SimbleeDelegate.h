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

@class Simblee;

@protocol SimbleeDelegate <NSObject>

@optional

- (void)didDiscover;
- (void)didDiscoverSimblee:(Simblee *)simblee;

- (void)didConnect;
- (void)didConnectSimblee:(Simblee *)simblee;

- (void)didNotConnect;
- (void)didNotConnectSimblee:(Simblee *)simblee;

- (void)didDisconnect;
- (void)didDisconnectSimblee:(Simblee *)simblee;

- (void)didLooseConnect;
- (void)didLooseConnectSimblee:(Simblee *)simblee;

- (void)didReceive:(NSData *)data;
- (void)didReceiveSimblee:(Simblee *)simblee;

- (void)bleUnsupported;
- (void)bleUnauthorized;
- (void)blePoweredOff;
- (void)blePoweredOn;

@end
